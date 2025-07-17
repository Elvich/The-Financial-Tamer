//
//  BankAccountsService.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 12.06.2025.
//

import Foundation

final class BankAccountsService: ObservableObject {
    
    // MARK: - Properties
    private let networkClient: NetworkClient
    private var bankAccounts: [BankAccount] = []
    
    // MARK: - Initialization
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    // MARK: - Public Methods
    func fetchAccounts() async throws -> [BankAccount] {
        let raw = try await networkClient.request(
            endpoint: "accounts",
            method: .get,
            body: nil,
            headers: nil
        )

        guard let array = raw as? [Any] else { 
            throw NSError(domain: "BankAccountsService", code: 2, userInfo: [
                NSLocalizedDescriptionKey: "Unexpected raw data format"
            ])
        }
        
        let accounts = try await withThrowingTaskGroup(of: BankAccount?.self) { group in
            for obj in array {
                group.addTask {
                    try await BankAccount.parse(jsonObject: obj)
                }
            }
            return try await group.reduce(into: [BankAccount]()) { result, account in
                if let account = account {
                    result.append(account)
                }
            }
        }
        return accounts
    }
    
    func getAccount(id: Int = 0, hardRefresh: Bool = false) async throws -> BankAccount {
        if bankAccounts.isEmpty || hardRefresh {
            bankAccounts = try await fetchAccounts()
        }

        guard id >= 0 && id < bankAccounts.count else {
            throw NSError(domain: "BankAccountsService", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Account with ID \(id) not found"
            ])
        }

        return bankAccounts[id]
    }
        
    func update(from account: inout BankAccount) async throws {
        // Находим индекс аккаунта по ID
        guard let index = bankAccounts.firstIndex(where: { $0.id == account.id }) else {
            throw NSError(domain: "BankAccountsService", code: 3, userInfo: [
                NSLocalizedDescriptionKey: "Account with ID \(account.id) not found for update"
            ])
        }
        
        // Сохраняем старое состояние для возможного отката
        let oldAccount = bankAccounts[index]
        
        // Обновляем дату изменения
        account.updatedAt = Date()
        
        print("[BankAccountsService] Локально обновляем аккаунт с id = \(account.id)")
        // Оптимистично обновляем локально на главном потоке
        await MainActor.run {
            bankAccounts[index] = account
        }
        
        do {
            // Сериализуем аккаунт в JSON
            let body = account.jsonObject
            // Отправляем PUT-запрос на сервер
            print("[BankAccountsService] Отправляем PUT на сервер для аккаунта id = \(account.id)")
            let raw = try await networkClient.request(
                endpoint: "accounts/\(account.id)",
                method: .put,
                body: body,
                headers: ["Content-Type": "application/json"]
            )
            // Парсим ответ сервера (если сервер возвращает обновлённый объект)
            if let updatedAccount = try? await BankAccount.parse(jsonObject: raw) {
                print("[BankAccountsService] Сервер успешно обновил аккаунт id = \(updatedAccount.id)")
                await MainActor.run {
                    bankAccounts[index] = updatedAccount
                }
            } else {
                print("[BankAccountsService] Сервер вернул неожиданный ответ для аккаунта id = \(account.id)")
            }
        } catch {
            print("[BankAccountsService] Ошибка при обновлении аккаунта id = \(account.id) на сервере: \(error)")
            // В случае ошибки откатываем локальные изменения
            await MainActor.run {
                bankAccounts[index] = oldAccount
            }
            print("[BankAccountsService] Откатили локальные изменения для аккаунта id = \(account.id)")
            throw error
        }
    }
}

