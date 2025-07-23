//
//  BankAccountsService.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 12.06.2025.
//

import Foundation
import SwiftData
import SwiftUI

final class BankAccountsService: ObservableObject {
    
    // MARK: - Properties
    private let networkClient: NetworkClient
    private let bankAccountsStorage = BankAccountsSwiftDataStorage()
    private var _backupStorage: BackupBankAccountStorage?
    
    var modelContext: ModelContext? {
        didSet {
            if modelContext != nil {
                _backupStorage = BackupBankAccountStorageSwiftData()
            }
        }
    }
    
    private var backupStorage: BackupBankAccountStorage {
        guard let storage = _backupStorage else {
            fatalError("BackupBankAccountStorage is not initialized. Set modelContext first.")
        }
        return storage
    }
    
    // MARK: - Initialization
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    // MARK: - Public Methods
    func fetchAccounts() async throws -> [BankAccount] {
        let raw = try await networkClient.request(
            endpoint: "accounts",
            method: .get,
            queryItems: nil,
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
        
        // Сохраняем в локальное хранилище
        for account in accounts {
            _ = await bankAccountsStorage.createAccount(account)
        }
        
        return accounts
    }
    
    func getAccount(id: Int = 0, hardRefresh: Bool = false) async throws -> BankAccount {
        var accounts: [BankAccount] = await bankAccountsStorage.getAllAccounts()
        
        if accounts.isEmpty || hardRefresh {
            accounts = try await fetchAccounts()
        }

        guard id >= 0 else {
            throw NSError(domain: "BankAccountsService", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "The ID cannot be negative"
            ])
        }
        
        if id == 0 { return accounts[0]}
        
        guard let account = accounts.first(where: { $0.id == id }) else {
            throw NSError(domain: "BankAccountsService", code: 3, userInfo: [
                NSLocalizedDescriptionKey: "Account with ID \(id) not found for update"
            ])
        }
        
        return account
    }
        
    func update(from account: inout BankAccount) async throws {
        do {
            // Обновляем дату изменения
            account.updatedAt = Date()
            
            // Сериализуем аккаунт в JSON
            let body = account.jsonObject
            
            // Отправляем PUT-запрос на сервер
            print("[BankAccountsService] Отправляем PUT на сервер для аккаунта id = \(account.id)")
            let raw = try await networkClient.request(
                endpoint: "accounts/\(account.id)",
                method: .put,
                queryItems: nil,
                body: body,
                headers: ["Content-Type": "application/json"]
            )
            
            // При успехе повторяем действие в локальном хранилище
            _ = await bankAccountsStorage.updateAccount(account)
            
            // Удаляем из бэкапа неактуальные операции
            backupStorage.removeAction(for: account.id)
            
            // Парсим ответ сервера (если сервер возвращает обновлённый объект)
            if let updatedAccount = try? await BankAccount.parse(jsonObject: raw) {
                print("[BankAccountsService] Сервер успешно обновил аккаунт id = \(updatedAccount.id)")
                _ = await bankAccountsStorage.updateAccount(updatedAccount)
            } else {
                print("[BankAccountsService] Сервер вернул неожиданный ответ для аккаунта id = \(account.id)")
            }
        } catch {
            print("[BankAccountsService] Ошибка при обновлении аккаунта id = \(account.id) на сервере: \(error)")
            
            // При провале добавляем операцию в бэкап
            let backupAction = BackupBankAccountAction(
                id: account.id,
                actionType: .update,
                account: account.toDTO(),
                timestamp: Date()
            )
            backupStorage.addAction(backupAction)
            
            throw error
        }
    }
}

