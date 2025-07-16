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
    
    func getAccount(_ id: Int = 0) async throws -> BankAccount {
        if bankAccounts.isEmpty {
            bankAccounts = try await fetchAccounts()
        }

        guard id >= 0 && id < bankAccounts.count else {
            throw NSError(domain: "BankAccountsService", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Account with ID \(id) not found"
            ])
        }

        return bankAccounts[id]
    }
    
    func update<Value>(id: Int, keyPath: WritableKeyPath<BankAccount, Value>, value: Value) async throws -> BankAccount {
        var account = try await getAccount(id)
        account[keyPath: keyPath] = value
        account.updatedAt = Date()
        
        await MainActor.run {
            bankAccounts[id] = account
        }
        
        return account
    }
    
    func update(from account: inout BankAccount) async throws {
        // Находим индекс аккаунта по ID
        guard let index = bankAccounts.firstIndex(where: { $0.id == account.id }) else {
            throw NSError(domain: "BankAccountsService", code: 3, userInfo: [
                NSLocalizedDescriptionKey: "Account with ID \(account.id) not found for update"
            ])
        }
        
        // Обновляем время изменения
        account.updatedAt = Date()
        
        // Обновляем аккаунт в массиве на главном потоке
        await MainActor.run {
            bankAccounts[index] = account
        }
    }
}

