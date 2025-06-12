//
//  TransactionCSV.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 12.06.2025.
//

import Foundation

extension Transaction{
    
    static func parse(csvString: String) -> Transaction?{
        let components = csvString.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                
                
        guard components.count == 8 else {
            return nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        let id: Int = Int(components[0]) ?? 0
        let accountId: Int = Int(components[1]) ?? 0
        let categoryId: Int = Int(components[2]) ?? 0
        let amount: Decimal = Decimal(string: (components[3] as String)) ?? 0
        let transactionDate: Date = dateFormatter.date(from: components[4]) ?? Date()
        let comment: String = components[5]
        let createdAt: Date = dateFormatter.date(from: components[6]) ?? Date()
        let updatedAt: Date = dateFormatter.date(from: components[7]) ?? Date()
        
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
}
