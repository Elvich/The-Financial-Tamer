//
//  TransactionSwiftDataEntity.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 19.07.2025.
//

import Foundation
import SwiftData

@Model
final class TransactionSwiftDataEntity {
    var id: Int32
    var amount: Decimal
    var transactionDate: Date
    var comment: String
    var createdAt: Date
    var updatedAt: Date
    var accountId: Int32
    var accountName: String
    var accountBalance: Decimal
    var accountCurrency: String
    var categoryId: Int32
    var categoryName: String
    var categoryEmoji: String
    var categoryDirection: String
    
    init(from transaction: Transaction) {
        self.id = Int32(transaction.id)
        self.amount = transaction.amount
        self.transactionDate = transaction.transactionDate
        self.comment = transaction.comment
        self.createdAt = transaction.createdAt
        self.updatedAt = transaction.updatedAt
        
        // Account data
        self.accountId = Int32(transaction.account.id)
        self.accountName = transaction.account.name
        self.accountBalance = transaction.account.balance
        self.accountCurrency = transaction.account.currency
        
        // Category data
        self.categoryId = Int32(transaction.category.id)
        self.categoryName = transaction.category.name
        self.categoryEmoji = String(transaction.category.emoji)
        self.categoryDirection = transaction.category.direction.rawValue
    }
    
    func toModel() -> Transaction? {
        let account = TransactionAccount(
            id: Int(accountId),
            name: accountName,
            balance: accountBalance,
            currency: accountCurrency
        )
        
        let category = Category(
            id: Int(categoryId),
            name: categoryName,
            emoji: categoryEmoji.first ?? "📊",
            direction: Direction(rawValue: categoryDirection) ?? .outcome
        )
        
        return Transaction(
            id: Int(id),
            account: account,
            category: category,
            amount: amount,
            transactionDate: transactionDate,
            comment: comment,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    func updateFromModel(_ transaction: Transaction) {
        self.id = Int32(transaction.id)
        self.amount = transaction.amount
        self.transactionDate = transaction.transactionDate
        self.comment = transaction.comment
        self.createdAt = transaction.createdAt
        self.updatedAt = transaction.updatedAt
        
        // Account data
        self.accountId = Int32(transaction.account.id)
        self.accountName = transaction.account.name
        self.accountBalance = transaction.account.balance
        self.accountCurrency = transaction.account.currency
        
        // Category data
        self.categoryId = Int32(transaction.category.id)
        self.categoryName = transaction.category.name
        self.categoryEmoji = String(transaction.category.emoji)
        self.categoryDirection = transaction.category.direction.rawValue
    }
} 