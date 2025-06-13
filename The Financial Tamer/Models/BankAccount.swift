//
//  BankAccount.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 07.06.2025.
//

import Foundation

struct BankAccount{
    let id: Int
    let userId: Int
    var name: String
    var balance: Decimal
    var currency: String
    let createdAt: Date
    var updatedAt: Date
}
 
extension BankAccount{
    static func parse(jsonObject: Any) -> BankAccount?{
        guard let dict = jsonObject as? [String: Any] else {
            return nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

        guard let id = dict["id"] as? Int,
              let userId = dict["userId"] as? Int,
              let name = dict["name"] as? String,
              
              
              //let balance = Decimal(string: (dict["balance"] as? String) ?? ""),
              let balance = Decimal(string: dict["balance"] as? String ?? "", locale: Locale(identifier: "en_US_POSIX")),
              
              let currency = dict["currency"] as? String,
              
              let createdAtString = dict["createdAt"] as? String,
              let createdAt = dateFormatter.date(from: createdAtString),
              
              let updatedAtString = dict["updatedAt"] as? String,
              let updatedAt = dateFormatter.date(from: updatedAtString)
        else {
            print("Error parsing Transaction")
            return nil
        }

        return BankAccount(
            id: id,
            userId: userId,
            name: name,
            balance: balance,
            currency: currency,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
