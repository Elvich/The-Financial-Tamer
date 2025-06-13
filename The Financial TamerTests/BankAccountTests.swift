//
//  BankAccountTests.swift
//  The Financial TamerTests
//
//  Created by Maksim Gritsuk on 13.06.2025.
//

import Testing
@testable import The_Financial_Tamer
import Foundation

struct BankAccountTests {
    
    let jsonObject: [String: Any] = [
        "id": 1,
        "userId": 1,
        "name": "Основной счёт",
        "balance": "1000.00",
        "currency": "RUB",
        "createdAt": "2025-06-13T16:05:56.890Z",
        "updatedAt": "2025-06-13T16:05:56.890Z"
    ]

    @Test func testParse() async throws {
        #expect(BankAccount.parse(jsonObject: jsonObject) != nil)
    }

}
