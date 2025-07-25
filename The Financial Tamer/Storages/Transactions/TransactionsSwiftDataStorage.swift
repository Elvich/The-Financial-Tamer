//
//  TransactionsSwiftDataStorage.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 19.07.2025.
//

import Foundation
import SwiftData
import SwiftUI

final class TransactionsSwiftDataStorage: TransactionsStorage {
    
    @Query private var transactions: [TransactionSwiftDataEntity]
    @Environment(\.modelContext) private var context
    
    func getAllTransactions() async -> [Transaction] {
        return transactions.compactMap { $0.toModel() }
    }
    
    func updateTransaction(_ transaction: Transaction) async -> Bool {
        if let existingEntity = transactions.first(where: { $0.id == transaction.id }) {
            existingEntity.updateFromModel(transaction)
            return true
        }
        return false
    }
    
    func deleteTransaction(id: Int) async -> Bool {
        guard let index = transactions.firstIndex(where: { $0.id == id }) else {
            return false
        }
        
        context.delete(transactions[index])
        return true
    }
    
    func createTransaction(_ transaction: Transaction) async -> Bool {
        if transactions.contains(where: { $0.id == transaction.id }) {
            return false
        }
        
        let entity = TransactionSwiftDataEntity(from: transaction)
        context.insert(entity)
        return true
    }
}
