//
//  Transaction.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 07.06.2025.
//

import Foundation

struct Transaction : Equatable{
    let id: Int
    let accountId: Int
    var categoryId: Int
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
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

        guard let id = dict["id"] as? Int,
              
              let accountId = dict["accountId"] as? Int,
              let categoryId = dict["categoryId"] as? Int,
              
              let amount = Decimal(string: (dict["amount"] as? String) ?? ""),
              
              let transactionDateString = dict["transactionDate"] as? String,
              let transactionDate = dateFormatter.date(from: transactionDateString),
              
              let comment = dict["comment"] as? String,
              
              let createdAtString = dict["createdAt"] as? String,
              let createdAt = dateFormatter.date(from: createdAtString),
              
              let updatedAtString = dict["updatedAt"] as? String,
              let updatedAt = dateFormatter.date(from: updatedAtString)
        else {
            print("Error parsing Transaction")
            return nil
        }

        return Transaction(
            id: id,
            accountId: accountId,
            categoryId: categoryId,
            amount: amount,
            transactionDate: transactionDate,
            comment: comment,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    var jsonObject: [String: Any] {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let value = Decimal(string: "500")!
        let doubleValue = Double(truncating: value as NSNumber)
        let formatted = String(format: "%.2f", doubleValue)
        
        return [
            "id": self.id,
            "accountId": self.accountId,
            "categoryId": self.categoryId,
            "amount": "\(formatted)",
            "transactionDate": dateFormatter.string(from: self.transactionDate),
            "comment": self.comment,
            "createdAt": dateFormatter.string(from: self.createdAt),
            "updatedAt": dateFormatter.string(from: self.updatedAt)
        ]
    }
}
