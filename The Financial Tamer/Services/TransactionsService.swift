//
//  TransactionsService.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 12.06.2025.
//

import Foundation
import Combine
import SwiftData

final class TransactionsService: ObservableObject {
    private let networkClient: NetworkClient
    private let dateService: DateService
    
    private let transactionsStorage = TransactionsSwiftDataStorage()
    private var _backupStorage: BackupStorage?
    var modelContext: ModelContext? {
        didSet {
            if let context = modelContext {
                _backupStorage = BackupStorageSwiftData()
            }
        }
    }
    
    private var backupStorage: BackupStorage {
        guard let storage = _backupStorage else {
            fatalError("BackupStorage is not initialized. Set modelContext first.")
        }
        return storage
    }

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
        self.dateService = DateService()
        // backupStorage будет инициализирован после установки modelContext
    }
    
    
    
    // MARK: - Fetch Transactions by Account and Period
    func fetchTransactions(accountId: Int, startDate: Date, endDate: Date) async throws -> [Transaction] {

        let startString = dateService.toStringDay(from: startDate)
        let endString = dateService.toStringDay(from: endDate)
        let queryItems = [
            URLQueryItem(name: "startDate", value: startString),
            URLQueryItem(name: "endDate", value: endString)
        ]
        do {
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
            // 2. Сохраняем новые операции в персистенс
            for transaction in transactions {
                _ = await transactionsStorage.createTransaction(transaction)
            }
            
            return transactions
        } catch {
            // 4. При ошибке — возвращаем данные из локального хранилища и бэкапа
            let localTransactions = await transactionsStorage.getAllTransactions()
            let backupActions = await backupStorage.getAllActions()
            let backupTransactions = backupActions.compactMap { $0.transaction }
            let all = localTransactions
            // Фильтруем по периоду
            let filtered = all.filter {
                $0.transactionDate >= startDate && $0.transactionDate <= endDate
            }
            return filtered
        }
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
        // Добавляем в backup
        let backupAction = BackupTransactionAction(
            id: transaction.id,
            actionType: .create,
            transaction: transaction.toDTO(),
            timestamp: Date()
        )
        backupStorage.addAction(backupAction)
        
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
        // Добавляем в backup
        let backupAction = BackupTransactionAction(
            id: transaction.id,
            actionType: .update,
            transaction: transaction.toDTO(),
            timestamp: Date()
        )
        backupStorage.addAction(backupAction)
        
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
        let result = await transactionsStorage.deleteTransaction(id: id)
        // Добавляем в backup
        let backupAction = BackupTransactionAction(
            id: id,
            actionType: .delete,
            transaction: nil,
            timestamp: Date()
        )
        backupStorage.addAction(backupAction)
        return result
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
