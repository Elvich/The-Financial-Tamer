//
//  TransactionsFileCache.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 11.06.2025.
//

import Foundation

final class TransactionsFileCache {
    private var transactions: [Transaction] = []
    private let fileURL: URL
    
    var transactionsArray: [Transaction] { return transactions }
    
    init(fileURL: URL) {
        self.fileURL = fileURL
        checkFileExists()
        transactions = loadTransactionsFromFile()
    }
    
    func add(_ transaction: Transaction) -> Bool {
        if transactions.contains(where: { $0.id == transaction.id }) { return false }
        transactions.append(transaction)
        
        Task{
            await self.saveTransactionsToFile(transactions, fileURL)
        }
        return true
    }
    
    func remove(_ id: Int) -> Bool {
        let countBefore = transactions.count
        transactions.removeAll { $0.id == id }
        let wasRemoved = (transactions.count < countBefore)
        
        Task{
            await self.saveTransactionsToFile(transactions, fileURL)
        }
        
        if wasRemoved { return true }
        else { return false }
    }
    
    private func checkFileExists() {
        let fileManager = FileManager.default
        
        if !fileManager.fileExists(atPath: fileURL.path) {
            do {
                print("Файл не найден. Создаём новый...")

                let emptyArrayData = "[]".data(using: .utf8)!
                
                try emptyArrayData.write(to: fileURL)
                
                print("Файл успешно создан по пути: \(fileURL.path)")
            } catch {
                print("Ошибка при создании файла: \(error)")
            }
        }
    }
    
    private func saveTransactionsToFile(_ transactions:[Transaction], _ filePath:URL) async {
        do {
            let dictionaries = transactions.map { transaction in
                transaction.jsonObject
            }

            let jsonData = try JSONSerialization.data(withJSONObject: dictionaries)

            try await withCheckedThrowingContinuation { continuation in
                DispatchQueue.global(qos: .utility).async {
                    do {
                        try jsonData.write(to: filePath)
                        continuation.resume(returning: ())
                    } catch {
                        continuation.resume(throwing: error)
                      }
                    }
                }

        } catch {
            print("Ошибка при сохранении транзакций: \(error)")
        }
    }
    
    private func loadTransactionsFromFile() -> [Transaction] {
        do {
            let data = try Data(contentsOf: fileURL)
            
            guard let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                print("Формат файла некорректен")
                return []
            }

            var parsedTransactions = jsonArray.compactMap { dict in
                Transaction.parse(jsonObject: dict)
            }
            
            parsedTransactions.sort { $0.id < $1.id }
            
            return parsedTransactions
            
        } catch {
            print("Ошибка при загрузке транзакций: \(error)")
            return []
        }
    }
    
    
}
