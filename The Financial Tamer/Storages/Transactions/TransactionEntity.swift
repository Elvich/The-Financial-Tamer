//
//  TransactionEntity.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 19.07.2025.
//

import Foundation
import CoreData

extension CoreDataTransactionEntity {
    func toModel() -> Transaction? {
        guard let accountName = accountName,
              let accountCurrency = accountCurrency,
              let accountBalance = accountBalance,
              let comment = comment,
              let categoryName = categoryName,
              let categoryEmoji = categoryEmoji,
              let categoryDirection = categoryDirection,
              let amount = amount,
              let transactionDate = transactionDate,
              let createdAt = createdAt,
              let updatedAt = updatedAt else {
            return nil
        }
        
        let account = TransactionAccount(
            id: Int(accountId),
            name: accountName,
            balance: accountBalance as Decimal,
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
            amount: amount as Decimal,
            transactionDate: transactionDate,
            comment: comment,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    func updateFromModel(_ transaction: Transaction) {
        self.id = Int32(transaction.id)
        self.amount = NSDecimalNumber(decimal: transaction.amount)
        self.transactionDate = transaction.transactionDate
        self.comment = transaction.comment
        self.createdAt = transaction.createdAt
        self.updatedAt = transaction.updatedAt
        
        // Account data
        self.accountId = Int32(transaction.account.id)
        self.accountName = transaction.account.name
        self.accountBalance = NSDecimalNumber(decimal: transaction.account.balance)
        self.accountCurrency = transaction.account.currency
        
        // Category data
        self.categoryId = Int32(transaction.category.id)
        self.categoryName = transaction.category.name
        self.categoryEmoji = String(transaction.category.emoji)
        self.categoryDirection = transaction.category.direction.rawValue
    }
} 