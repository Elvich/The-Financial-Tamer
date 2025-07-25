//
//  Transaction.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 07.06.2025.
//

import Foundation
import SwiftData

@Model
final class Transaction: Sendable {
    @Attribute(.unique)
    var id: Int
    var account: TransactionAccount
    var category: Category
    var amount: Decimal
    var transactionDate: Date
    var comment: String
    var createdAt: Date
    var updatedAt: Date
    
    init(id: Int, account: TransactionAccount, category: Category, amount: Decimal, transactionDate: Date, comment: String, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.account = account
        self.category = category
        self.amount = amount
        self.transactionDate = transactionDate
        self.comment = comment
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension Transaction{
    
    static func parse(jsonObject: Any) async throws -> Transaction?{
        guard let dict = jsonObject as? [String: Any] else {
            return nil
        }
        
        let dateService = DateService()
        
        guard let id = dict["id"] as? Int,
              

            let account = try await TransactionAccount.parse(jsonObject: dict["account"] as Any),
            let category = Category.parse(jsonObject: dict["category"] as Any),
              
            let amount = Decimal(string: (dict["amount"] as? String) ?? ""),
              
            let transactionDateString = dict["transactionDate"] as? String,
            let transactionDate = dateService.toDate(from: transactionDateString),
              
            let comment = dict["comment"] as? String,
              
            let createdAtString = dict["createdAt"] as? String,
            let createdAt = dateService.toDate(from: createdAtString),
              
            let updatedAtString = dict["updatedAt"] as? String,
            let updatedAt = dateService.toDate(from: updatedAtString)
        else {
            print("Error parsing Transaction")
            return nil
        }

        return Transaction(
            id: id,
            account: account,
            category: category,
            amount: amount,
            transactionDate: transactionDate,
            comment: comment,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    var jsonObject: [String: Any] {
        
        let dateService = DateService()
        
        return [
            "id": self.id,
            "account": self.account,
            "category": self.category,
            "amount": self.amount,
            "transactionDate": dateService.toString(from: self.transactionDate),
            "comment": self.comment,
            "createdAt": dateService.toString(from: self.createdAt),
            "updatedAt": dateService.toString(from: self.updatedAt)
        ]
    }
    
    var jsonObjectPOST: [String: Any] {
        
        let dateService = DateService()
        
        return [
            "accountId": self.account.id,
            "categoryId": self.category.id,
            "amount": self.amount,
            "transactionDate": dateService.toString(from: self.transactionDate),
            "comment": self.comment,
        ]
    }
}

struct TransactionDTO: Codable, Sendable {
    let id: Int
    let account: TransactionAccount
    let category: Category
    let amount: Decimal
    let transactionDate: Date
    let comment: String
    let createdAt: Date
    let updatedAt: Date
}

extension Transaction {
    func toDTO() -> TransactionDTO {
        return TransactionDTO(
            id: self.id,
            account: self.account,
            category: self.category,
            amount: self.amount,
            transactionDate: self.transactionDate,
            comment: self.comment,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

extension TransactionDTO {
    func toModel() -> Transaction {
        return Transaction(
            id: self.id,
            account: self.account,
            category: self.category,
            amount: self.amount,
            transactionDate: self.transactionDate,
            comment: self.comment,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}
