//
//  Transaction.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 07.06.2025.
//

import Foundation

struct Transaction: Hashable{
    let id: Int
    let account: BankAccount
    var category: Category
    var amount: Decimal
    var transactionDate: Date
    var comment: String
    let createdAt: Date
    var updatedAt: Date
}

extension Transaction{
    
    static func parse(jsonObject: Any) -> Transaction?{
        guard let dict = jsonObject as? [String: Any] else {
            return nil
        }
        
        guard let id = dict["id"] as? Int,
              
            let account = BankAccount.parse(jsonObject: dict["account"] as Any),
            let category = Category.parse(jsonObject: dict["category"] as Any),
              
            let amount = Decimal(string: (dict["amount"] as? String) ?? ""),
              
            let transactionDateString = dict["transactionDate"] as? String,
            let transactionDate = DateService.shared.toDate(from: transactionDateString),
              
            let comment = dict["comment"] as? String,
              
            let createdAtString = dict["createdAt"] as? String,
            let createdAt = DateService.shared.toDate(from: createdAtString),
              
            let updatedAtString = dict["updatedAt"] as? String,
            let updatedAt = DateService.shared.toDate(from: updatedAtString)
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
        
        let value = Decimal(string: "500")!
        let doubleValue = Double(truncating: value as NSNumber)
        let formatted = String(format: "%.2f", doubleValue)
        
        return [
            "id": self.id,
            "account": self.account,
            "category": self.category,
            "amount": "\(formatted)",
            "transactionDate": DateService.shared.toString(from: self.transactionDate),
            "comment": self.comment,
            "createdAt": DateService.shared.toString(from: self.createdAt),
            "updatedAt": DateService.shared.toString(from: self.updatedAt)
        ]
    }
}
