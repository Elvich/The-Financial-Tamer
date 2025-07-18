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
    @Published private(set) var transactions: [Transaction] = []
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
        self.dateService = DateService()
    }
    
    // MARK: - Fetch Transactions by Account and Period
    func fetchTransactions(accountId: Int, startDate: Date = Date(), endDate: Date = Date()) async throws -> [Transaction] {
        let startString = dateService.toStringDay(from: startDate)
        let endString = dateService.toStringDay(from: endDate)
        
        let endpoint = "transactions/account/\(accountId)/period?startDate=\(startString)&endDate=\(endString)"
        let raw = try await networkClient.request(
            endpoint: endpoint,
            method: .get,
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
        
        print(transactions)
        return transactions
    }
    
    // MARK: - Add Transaction
    func add(_ transaction: Transaction) async throws -> Transaction {
        let body = transaction.jsonObjectPOST
        let raw = try await networkClient.request(
            endpoint: "transactions",
            method: .post,
            body: body,
            headers: ["Content-Type": "application/json"]
        )
        //guard let newTransaction = try? await Transaction.parse(jsonObject: raw) else {
        //    throw NSError(domain: "TransactionsService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to parse new transaction"])
        //}
        //await MainActor.run {
        //    self.transactions.append(newTransaction)
        //}
        
        
        return transaction
    }
    
    // MARK: - Update Transaction
    func update(_ transaction: Transaction) async throws -> Transaction {
        let body = transaction.jsonObjectPOST
        let raw = try await networkClient.request(
            endpoint: "transactions/\(transaction.id)",
            method: .put,
            body: body,
            headers: ["Content-Type": "application/json"]
        )
        //guard let updatedTransaction = try? await Transaction.parse(jsonObject: raw) else {
        //    throw NSError(domain: "TransactionsService", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to parse updated transaction"])
        //}
        if let index = transactions.firstIndex(where: { $0.id == transaction.id }) {
            await MainActor.run {
                self.transactions[index] = transaction
            }
        }
        return transaction
    }
    
    // MARK: - Delete Transaction
    func delete(id: Int) async throws -> Bool {
        _ = try await networkClient.request(
            endpoint: "transactions/\(id)",
            method: .delete,
            body: nil,
            headers: nil
        )
        if let index = transactions.firstIndex(where: { $0.id == id }) {
            await MainActor.run {
                self.transactions.remove(at: index)
            }
            return true
        } else {
            return false
        }
    }
    
    // MARK: - Local Filtering (optional, for convenience)
    func getTransactions(_ start: Date, _ end: Date) async throws -> [Transaction] {
        let all = transactions
        return all.filter {
            $0.transactionDate >= start && $0.transactionDate <= end
        }
    }
    
    func getTransactions(start: Date, end: Date, direction: Direction) -> [Transaction] {
        
        if transactions.isEmpty {
            Task
            {
                transactions = try await fetchTransactions(accountId: Utility.accountId)
            }
        }
        
        let filtered: [Transaction] = self.transactions.filter {
            $0.category.direction == direction
        }
        return filtered.filter {
            $0.transactionDate >= start && $0.transactionDate <= end
        }
    }
    
    func getTransactionsAsync(start: Date, end: Date, direction: Direction) async throws -> [Transaction] {
        
        if transactions.isEmpty {
            transactions = try await fetchTransactions(accountId: Utility.accountId)
        }
        
        let filtered: [Transaction] = self.transactions.filter {
            $0.category.direction == direction
        }
        return filtered.filter {
            $0.transactionDate >= start && $0.transactionDate <= end
        }
    }
}
