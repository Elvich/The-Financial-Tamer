//
//  TransactionsSwiftDataStorage.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 19.07.2025.
//

import Foundation
import SwiftData
import SwiftUI
import _SwiftData_SwiftUI

final class TransactionsSwiftDataStorage: TransactionsStorage {
    
    @Query private var transactions: [Transaction]
    @Environment(\.modelContext) private var context
    
    func getAllTransactions() async -> [Transaction] {
        transactions
    }
    
    func updateTransaction(_ transaction: Transaction) async -> Bool {
        context.insert(transaction)
        return true 
    }
    
    func deleteTransaction(id: Int) async -> Bool {
        guard let index = transactions.firstIndex(where: {$0.id == id}) else {
            return false
        }
        
        context.delete(transactions[index])
        return true
    }
    
    func createTransaction(_ transaction: Transaction) async -> Bool {
        context.insert(transaction)
        return true
    }
    
    
}
