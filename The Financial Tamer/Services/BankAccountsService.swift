//
//  BankAccountsService.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 12.06.2025.
//

import Foundation

final class BankAccountsService {
    
    private var bankAccounts: [BankAccount] = [
        BankAccount(id: 0, userId: 0, name: "Иван Иванович", balance: 100.00, currency: "RUB", createdAt: Date(), updatedAt: Date())
    ]

    
    func getAccount(_ id: Int = 0) async throws -> BankAccount {
        guard id >= 0 && id < bankAccounts.count else {
            throw NSError(domain: "BankAccountsService", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Account with ID $id) not found"
            ])
        }

        return bankAccounts[id]
    }

    
    func update<Value>(id: Int, keyPath: WritableKeyPath<BankAccount, Value>, value: Value) async throws -> BankAccount {

        var account = try await getAccount(id)
        account[keyPath: keyPath] = value
        account.updatedAt = Date()
        bankAccounts[id] = account

        return account
    }
}

extension BankAccount{
    enum chengesKeys: String, CodingKey {
        case name = "name"
        case balance = "balance"
        case currency = "currency"
    }
}
