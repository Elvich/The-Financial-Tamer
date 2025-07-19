//
//  BankAccountEntity.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 19.07.2025.
//

import Foundation
import CoreData

extension CoreDataBankAccountEntity {
    func toModel() -> BankAccount? {
        guard let name = name,
              let currency = currency,
              let balance = balance,
              let createdAt = createdAt,
              let updatedAt = updatedAt else {
            return nil
        }
        
        return BankAccount(
            id: Int(id),
            userId: Int(userId),
            name: name,
            balance: balance as Decimal,
            currency: currency,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    func updateFromModel(_ account: BankAccount) {
        self.id = Int32(account.id)
        self.userId = Int32(account.userId)
        self.name = account.name
        self.balance = NSDecimalNumber(decimal: account.balance)
        self.currency = account.currency
        self.createdAt = account.createdAt
        self.updatedAt = account.updatedAt
    }
} 