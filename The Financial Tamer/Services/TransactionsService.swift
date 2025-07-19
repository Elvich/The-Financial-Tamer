//
//  TransactionsService.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 12.06.2025.
//

import Foundation
import Combine

final class TransactionsService: ObservableObject {
    private let networkClient: NetworkClient
    private let dateService: DateService
    
    private let transactionsStorage = TransactionsSwiftDataStorage()
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
        self.dateService = DateService()
    }
    
    // MARK: - Fetch Transactions by Account and Period
    func fetchTransactions(accountId: Int, startDate: Date, endDate: Date) async throws -> [Transaction] {
        let startString = dateService.toStringDay(from: startDate)
        let endString = dateService.toStringDay(from: endDate)
        let queryItems = [
            URLQueryItem(name: "startDate", value: startString),
            URLQueryItem(name: "endDate", value: endString)
        ]
        let raw = try await networkClient.request(
            endpoint: "transactions/account/\(accountId)/period",
            method: .get,
            queryItems: queryItems,
            body: nil,
            headers: nil
        )
        guard let array = raw as? [Any] else {
            throw NSError(domain: "TransactionsService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unexpected raw data format"])
        }
        let transactions = try await withThrowingTaskGroup(of: Transaction?.self) { group in
            for obj in array {
                group.addTask {
                    try await Transaction.parse(jsonObject: obj)
                }
            }
            return try await group.reduce(into: [Transaction]()) { result, transaction in
                if let transaction = transaction {
                    result.append(transaction)
                }
            }
        }
        return transactions
    }
    
    // MARK: - Add Transaction
    func add(_ transaction: Transaction) async throws -> Transaction {
        let body = transaction.jsonObjectPOST
        _ = try await networkClient.request(
            endpoint: "transactions",
            method: .post,
            queryItems: nil,
            body: body,
            headers: ["Content-Type": "application/json"]
        )
        //guard let newTransaction = try? await Transaction.parse(jsonObject: raw) else {
        //    throw NSError(domain: "TransactionsService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to parse new transaction"])
        //}
        //await MainActor.run {
        //    self.transactions.append(newTransaction)
        //}
        _ = await transactionsStorage.createTransaction(transaction)
        
        return transaction
    }
    
    // MARK: - Update Transaction
    func update(_ transaction: Transaction) async throws -> Transaction {
        let body = transaction.jsonObjectPOST
        _ = try await networkClient.request(
            endpoint: "transactions/\(transaction.id)",
            method: .put,
            queryItems: nil,
            body: body,
            headers: ["Content-Type": "application/json"]
        )
        
        _ = await transactionsStorage.updateTransaction(transaction)
        
        return transaction
    }
    
    // MARK: - Delete Transaction
    func delete(id: Int) async throws -> Bool {
        _ = try await networkClient.request(
            endpoint: "transactions/\(id)",
            method: .delete,
            queryItems: nil,
            body: nil,
            headers: nil
        )
        return await transactionsStorage.deleteTransaction(id: id)
    }
    
    // MARK: - Local Filtering (optional, for convenience)
    func getTransactions(_ start: Date, _ end: Date) async throws -> [Transaction] {
        let all = await transactionsStorage.getAllTransactions()
        return all.filter {
            $0.transactionDate >= start && $0.transactionDate <= end
        }
    }
    
    
    func getTransactions(start: Date, end: Date, direction: Direction, hardRefresh: Bool = false) async throws -> [Transaction] {
        
        var transactions: [Transaction] = await transactionsStorage.getAllTransactions()
        
        if transactions.isEmpty || hardRefresh {
            transactions = try await fetchTransactions(accountId: Utility.accountId, startDate: start, endDate: end)
        }
        
        for transaction in transactions {
            _ = await transactionsStorage.createTransaction(transaction)
        }
        
        let filtered: [Transaction] = transactions.filter {
            $0.category.direction == direction
        }
        return filtered.filter {
            $0.transactionDate >= start && $0.transactionDate <= end
        }
    }
}
