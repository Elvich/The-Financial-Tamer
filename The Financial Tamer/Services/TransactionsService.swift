//
//  TransactionsService.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 12.06.2025.
//

import Foundation

final class TransactionsService {
    
    private var transactions: [Transaction] = [
        Transaction(id: 0, account: BankAccount(id: 0, userId: 0, name: "Иван Иванович", balance: 100.00, currency: "RUB", createdAt: Date(), updatedAt: Date()), category: Category(id: 2, name: "ЯндексGO", emoji: "🚕", direction: .outcome), amount: 150.00, transactionDate: Date(), comment: "Люблю такси", createdAt: Date(), updatedAt: Date())
    ]

    
    func getTransactions(_ start: Date, _ end: Date) async throws -> [Transaction] {
        return transactions.filter{ $0.transactionDate >= start && $0.transactionDate <= end }
    }
    
    func getTransactions() async throws -> [Transaction] {
        return transactions.filter{ $0.transactionDate == Date() }
    }

    func add(_ transaction: Transaction) async throws -> Transaction {
        transactions.append(transaction)
        return transaction
    }

    
    func update<Value>(id: Int, keyPath: WritableKeyPath<Transaction, Value>, value: Value) async throws -> Transaction {
        guard let index = transactions.firstIndex(where: { $0.id == id }) else {
            throw NSError(domain: "TransactionsService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Transaction not found"])
        }

        var transaction = transactions[index]

        transaction[keyPath: keyPath] = value
        transaction.updatedAt = Date()

        transactions[index] = transaction

        return transaction
    }

    func delete(id: Int) async -> Bool {
        if let index = transactions.firstIndex(where: { $0.id == id }) {
            transactions.remove(at: index)
            return true
        } else {
            return false
        }
    }
}

