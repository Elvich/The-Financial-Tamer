//
//  TransactionsService.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 12.06.2025.
//

import Foundation

final class TransactionsService {
    
    private var transactions: [Transaction] = [
        Transaction(id: 0, account: BankAccount(id: 0, userId: 0, name: "Иван Иванович", balance: 150000.00, currency: "RUB", createdAt: Date(), updatedAt: Date()), category: Category(id: 2, name: "ЯндексGO", emoji: "🚕", direction: .outcome), amount: 150.00, transactionDate: Date(), comment: "Люблю такси", createdAt: Date(), updatedAt: Date()),
        
        Transaction(id: 1, account: BankAccount(id: 0, userId: 0, name: "Иван Иванович", balance: 150000.00, currency: "RUB", createdAt: Date(), updatedAt: Date()), category: Category(id: 1, name: "ЗП", emoji: "💰", direction: .income), amount: 300000.00, transactionDate: Date(), comment: "Ура, я могу покушать =)", createdAt: Date(), updatedAt: Date()),
        
        Transaction(id: 2, account: BankAccount(id: 0, userId: 0, name: "Иван Иванович", balance: 150000.00, currency: "RUB", createdAt: Date(), updatedAt: Date()), category: Category(id: 4, name: "Помощь рядом", emoji: "💚", direction: .outcome), amount: 500.00, transactionDate: Date(), comment: "Люблю такси", createdAt: Date(), updatedAt: Date()),
        
        Transaction(id: 3, account: BankAccount(id: 0, userId: 0, name: "Иван Иванович", balance: 150000.00, currency: "RUB", createdAt: Date(), updatedAt: Date()), category: Category(id: 0, name: "Маркет", emoji: "🚚", direction: .outcome), amount: 236.00, transactionDate: Date(), comment: "Люблю такси", createdAt: Date(), updatedAt: Date()),
    ]

    
    func getTransactions(_ start: Date, _ end: Date) async throws -> [Transaction] {
        return transactions.filter{ $0.transactionDate >= start && $0.transactionDate <= end }
    }
    
    func getTransactions(start: Date, end: Date, direction: Direction) -> [Transaction] {
        
        let transactions: [Transaction] = self.transactions.filter { $0.category.direction == direction }
        
        return transactions.filter{ $0.transactionDate >= start && $0.transactionDate <= end }
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

