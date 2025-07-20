//
//  DataMigrationService.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 19.07.2025.
//

import Foundation
import SwiftData
import CoreData

final class DataMigrationService {
    static let shared = DataMigrationService()
    
    private init() {}
    
    func migrateData(from oldStorageType: StorageType, to newStorageType: StorageType) async {
        print("Starting data migration from \(oldStorageType.displayName) to \(newStorageType.displayName)")
        
        do {
            // Мигрируем транзакции
            await migrateTransactions(from: oldStorageType, to: newStorageType)
            
            // Мигрируем банковские счета
            await migrateBankAccounts(from: oldStorageType, to: newStorageType)
            
            // Мигрируем категории
            await migrateCategories(from: oldStorageType, to: newStorageType)
            
            print("Data migration completed successfully")
        } catch {
            print("Data migration failed: \(error)")
        }
    }
    
    private func migrateTransactions(from oldType: StorageType, to newType: StorageType) async {
        let oldStorage = createTransactionsStorage(for: oldType)
        let newStorage = createTransactionsStorage(for: newType)
        
        let transactions = await oldStorage.getAllTransactions()
        
        for transaction in transactions {
            _ = await newStorage.createTransaction(transaction)
        }
        
        print("Migrated \(transactions.count) transactions")
    }
    
    private func migrateBankAccounts(from oldType: StorageType, to newType: StorageType) async {
        let oldStorage = createBankAccountsStorage(for: oldType)
        let newStorage = createBankAccountsStorage(for: newType)
        
        let accounts = await oldStorage.getAllAccounts()
        
        for account in accounts {
            _ = await newStorage.createAccount(account)
        }
        
        print("Migrated \(accounts.count) bank accounts")
    }
    
    private func migrateCategories(from oldType: StorageType, to newType: StorageType) async {
        let oldStorage = createCategoriesStorage(for: oldType)
        let newStorage = createCategoriesStorage(for: newType)
        
        let categories = await oldStorage.getAllCategories()
        
        await newStorage.saveCategories(categories)
        
        print("Migrated \(categories.count) categories")
    }
    
    private func createTransactionsStorage(for type: StorageType) -> TransactionsStorage {
        switch type {
        case .swiftData:
            return TransactionsSwiftDataStorage()
        case .coreData:
            return TransactionsCoreDataStorage()
        }
    }
    
    private func createBankAccountsStorage(for type: StorageType) -> BankAccountsStorage {
        switch type {
        case .swiftData:
            return BankAccountsSwiftDataStorage()
        case .coreData:
            return BankAccountsCoreDataStorage()
        }
    }
    
    private func createCategoriesStorage(for type: StorageType) -> CategoriesStorage {
        switch type {
        case .swiftData:
            return CategoriesSwiftDataStorage()
        case .coreData:
            return CategoriesCoreDataStorage()
        }
    }
} 