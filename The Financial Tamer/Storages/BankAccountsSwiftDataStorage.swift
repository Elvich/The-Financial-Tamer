//
//  BankAccountsSwiftDataStorage.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 19.07.2025.
//

import Foundation
import SwiftData
import SwiftUI
import _SwiftData_SwiftUI

final class BankAccountsSwiftDataStorage: BankAccountsStorage {
    
    @Query private var accounts: [BankAccountEntity]
    @Environment(\.modelContext) private var context
    
    func getAllAccounts() async -> [BankAccount] {
        return accounts.map { $0.toModel() }
    }
    
    func updateAccount(_ account: BankAccount) async -> Bool {
        if let existingEntity = accounts.first(where: { $0.id == account.id }) {
            existingEntity.updateFromModel(account)
            return true
        }
        return false
    }
    
    func deleteAccount(id: Int) async -> Bool {
        guard let index = accounts.firstIndex(where: { $0.id == id }) else {
            return false
        }
        
        context.delete(accounts[index])
        return true
    }
    
    func createAccount(_ account: BankAccount) async -> Bool {
        if accounts.contains(where: { $0.id == account.id }) {
            return false
        }
        
        let entity = BankAccountEntity(from: account)
        context.insert(entity)
        return true
    }
} 