//
//  TransactionAccount.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 19.07.2025.
//

import Foundation

struct TransactionAccount: Hashable, Equatable, Codable {
    let id: Int
    let name: String
    let balance: Decimal
    let currency: String
}

struct TransactionAccountDTO: Codable {
    let id: Int
    let name: String
    let balance: Decimal
    let currency: String
}

extension TransactionAccount{
    static func parse(jsonObject: Any) async throws -> TransactionAccount?{
        guard let dict = jsonObject as? [String: Any] else {
            return nil
        }
        
        
        guard let id = dict["id"] as? Int,
              let name = dict["name"] as? String,
              let balance = Decimal(string: dict["balance"] as? String ?? "", locale: Locale(identifier: "en_US_POSIX")),
              let currency = dict["currency"] as? String
              
        else {
            print("Error parsing Account")
            return nil
        }
        
        return TransactionAccount(id: id, name: name, balance: balance, currency: currency)
    }
    
    static func parse(account: BankAccount) async throws -> TransactionAccount?{
        return TransactionAccount(id: account.id, name: account.name, balance: account.balance, currency: account.currency)
    }
}

extension TransactionAccount {
    func toDTO() -> TransactionAccountDTO {
        return TransactionAccountDTO(
            id: self.id,
            name: self.name,
            balance: self.balance,
            currency: self.currency
        )
    }
}

extension TransactionAccountDTO {
    func toModel() -> TransactionAccount {
        return TransactionAccount(
            id: self.id,
            name: self.name,
            balance: self.balance,
            currency: self.currency
        )
    }
}
