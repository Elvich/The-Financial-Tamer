//
//  CategoryTest.swift
//  The Financial TamerTests
//
//  Created by Maksim Gritsuk on 13.06.2025.
//

import Testing
@testable import The_Financial_Tamer
import Foundation

struct CategoryTest {
    
    let jsonObject: [String: Any] = [
        "id": 1,
        "name": "Зарплата",
        "emoji": "💰",
        "isIncome": true
    ]

    @Test func testParse() async throws {
        #expect(Category.parse(jsonObject: jsonObject) != nil)
    }

}
