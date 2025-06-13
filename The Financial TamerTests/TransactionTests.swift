//
//  TransactionTests.swift
//  The Financial TamerTests
//
//  Created by Maksim Gritsuk on 10.06.2025.
//

import Testing
@testable import The_Financial_Tamer
import Foundation

struct TransactionTests {
    
    
    let transactionJson: [String:Any] = [
        "id": 1,
        "account": [
            "id": 1,
            "userId": 1,
            "name": "Основной счёт",
            "balance": "1000.00",
            "currency": "RUB",
            "createdAt": "2025-06-13T16:05:56.890Z",
            "updatedAt": "2025-06-13T16:05:56.890Z"
        ],
        "category": [
            "id": 1,
            "name": "Зарплата",
            "emoji": "💰",
            "isIncome": true
        ],
        "amount": "500.00",
        "transactionDate": "2025-06-09T23:33:48.883Z",
        "comment": "Зарплата за месяц",
        "createdAt": "2025-06-09T23:33:48.883Z",
        "updatedAt": "2025-06-09T23:33:48.883Z"
    ]
    

    @Test func testParse() async throws {
        #expect(Transaction.parse(jsonObject: transactionJson) != nil)
    }
    
    @Test func testJsonObject() async throws {
        let transaction = Transaction.parse(jsonObject: transactionJson)!
        let newTransactionJson = transaction.jsonObject
        #expect(newTransactionJson["id"] as? Int == transactionJson["id"] as? Int)
        
        #expect(newTransactionJson["amount"] as? String == transactionJson["amount"] as? String)
        
        #expect(newTransactionJson["transactionDate"] as? String == transactionJson["transactionDate"] as? String)
        
        #expect(newTransactionJson["comment"] as? String == transactionJson["comment"] as? String)
        
        #expect(newTransactionJson["createdAt"] as? String == transactionJson["createdAt"] as? String)
        #expect(newTransactionJson["updatedAt"] as? String == transactionJson["updatedAt"] as? String)
    }

}
