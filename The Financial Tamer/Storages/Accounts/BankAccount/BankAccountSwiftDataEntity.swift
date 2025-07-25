//
//  BankAccountSwiftDataEntity.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 19.07.2025.
//

import Foundation
import SwiftData

@Model
final class BankAccountSwiftDataEntity {
    var id: Int32
    var userId: Int32
    var name: String
    var balance: Decimal
    var currency: String
    var createdAt: Date
    var updatedAt: Date
    
    init(from account: BankAccount) {
        self.id = Int32(account.id)
        self.userId = Int32(account.userId)
        self.name = account.name
        self.balance = account.balance
        self.currency = account.currency
        self.createdAt = account.createdAt
        self.updatedAt = account.updatedAt
    }
    
    func toModel() -> BankAccount? {
        return BankAccount(
            id: Int(id),
            userId: Int(userId),
            name: name,
            balance: balance,
            currency: currency,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    func updateFromModel(_ account: BankAccount) {
        self.id = Int32(account.id)
        self.userId = Int32(account.userId)
        self.name = account.name
        self.balance = account.balance
        self.currency = account.currency
        self.createdAt = account.createdAt
        self.updatedAt = account.updatedAt
    }
} 