//
//  TransactionCSV.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 12.06.2025.
//

import Foundation

extension Transaction{
    
    enum ParseError: Error {
        case invalidFormat
        case missingComponents
        case invalidId
        case invalidAccount
        case invalidCategory
        case invalidAmount
        case invalidDate(String)
    }
    
    static func parse(csvString: String) throws -> Transaction?{
        let components = csvString
            .components(separatedBy: CharacterSet(charactersIn: ",;"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
                
        guard components.count == 8 else {
            return nil
        }
        
        
        guard components.count == 8 else {
            throw ParseError.missingComponents
        }

        guard let id = Int(components[0]) else {
            throw ParseError.invalidId
        }

        let account = BankAccount.parse(jsonObject: components[1])!

        let category = Category.parse(jsonObject: components[2])!
        

        guard let amount = Decimal(string: components[3]) else {
            throw ParseError.invalidAmount
        }
        
        guard let transactionDate = DateService.shared.toDate(from: components[4]) else {
            throw ParseError.invalidDate("transactionDate")
        }

        let comment = components[5]
        
        guard let createdAt = DateService.shared.toDate(from: components[6]) else {
            throw ParseError.invalidDate("createdAt")
        }

        guard let updatedAt = DateService.shared.toDate(from: components[7]) else {
            throw ParseError.invalidDate("updatedAt")
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
}
