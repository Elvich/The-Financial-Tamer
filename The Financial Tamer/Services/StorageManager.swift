//
//  StorageManager.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 19.07.2025.
//

import Foundation
import SwiftData
import CoreData

enum StorageType: String, CaseIterable {
    case swiftData = "SwiftData"
    case coreData = "CoreData"
    
    var displayName: String {
        switch self {
        case .swiftData:
            return "SwiftData"
        case .coreData:
            return "Core Data"
        }
    }
}

final class StorageManager: ObservableObject {
    static let shared = StorageManager()
    
    @Published var currentStorageType: StorageType {
        didSet {
            UserDefaults.standard.set(currentStorageType.rawValue, forKey: "StorageType")
            migrateDataIfNeeded()
        }
    }
    
    private init() {
        let savedType = UserDefaults.standard.string(forKey: "StorageType") ?? StorageType.swiftData.rawValue
        self.currentStorageType = StorageType(rawValue: savedType) ?? .swiftData
    }
    
    func createTransactionsStorage() -> TransactionsStorage {
        switch currentStorageType {
        case .swiftData:
            return TransactionsSwiftDataStorage()
        case .coreData:
            return TransactionsCoreDataStorage()
        }
    }
    
    func createBankAccountsStorage() -> BankAccountsStorage {
        switch currentStorageType {
        case .swiftData:
            return BankAccountsSwiftDataStorage()
        case .coreData:
            return BankAccountsCoreDataStorage()
        }
    }
    
    func createCategoriesStorage() -> CategoriesStorage {
        switch currentStorageType {
        case .swiftData:
            return CategoriesSwiftDataStorage()
        case .coreData:
            return CategoriesCoreDataStorage()
        }
    }
    
    private func migrateDataIfNeeded() {
        // Получаем предыдущий тип хранилища
        let previousType = UserDefaults.standard.string(forKey: "PreviousStorageType")
        if let previousTypeString = previousType,
           let previousStorageType = StorageType(rawValue: previousTypeString),
           previousStorageType != currentStorageType {
            
            Task {
                await DataMigrationService.shared.migrateData(
                    from: previousStorageType,
                    to: currentStorageType
                )
            }
        }
        
        // Сохраняем текущий тип как предыдущий
        UserDefaults.standard.set(currentStorageType.rawValue, forKey: "PreviousStorageType")
    }
} 