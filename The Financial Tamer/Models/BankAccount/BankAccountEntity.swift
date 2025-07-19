//
//  BankAccountEntity.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 19.07.2025.
//

import Foundation
import SwiftData

@Model
final class BankAccountEntity {
    @Attribute(.unique) var id: Int
    var userId: Int
    var name: String
    var balance: Decimal
    var currency: String
    var createdAt: Date
    var updatedAt: Date
    
    init(from account: BankAccount) {
        self.id = account.id
        self.userId = account.userId
        self.name = account.name
        self.balance = account.balance
        self.currency = account.currency
        self.createdAt = account.createdAt
        self.updatedAt = account.updatedAt
    }
    
    func toModel() -> BankAccount {
        return BankAccount(
            id: self.id,
            userId: self.userId,
            name: self.name,
            balance: self.balance,
            currency: self.currency,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
    
    func updateFromModel(_ account: BankAccount) {
        self.name = account.name
        self.balance = account.balance
        self.currency = account.currency
        self.updatedAt = account.updatedAt
    }
} 