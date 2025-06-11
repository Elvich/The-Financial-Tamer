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
    enum chengesKeys: String, CodingKey {
        case name = "name"
        case balance = "balance"
        case currency = "currency"
    }
}
