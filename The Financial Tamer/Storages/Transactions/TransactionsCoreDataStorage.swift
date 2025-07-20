//
//  TransactionsCoreDataStorage.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 19.07.2025.
//

import Foundation
import CoreData

final class TransactionsCoreDataStorage: TransactionsStorage {
    private let persistentContainer: NSPersistentContainer
    
    init() {
        persistentContainer = NSPersistentContainer(name: "FinancialTamerModel")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error)")
            }
        }
    }
    
    private var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func getAllTransactions() async -> [Transaction] {
        let request: NSFetchRequest<CoreDataTransactionEntity> = CoreDataTransactionEntity.fetchRequest()
        
        do {
            let entities = try context.fetch(request)
            return entities.compactMap { $0.toModel() }
        } catch {
            print("Failed to fetch transactions: \(error)")
            return []
        }
    }
    
    func updateTransaction(_ transaction: Transaction) async -> Bool {
        let request: NSFetchRequest<CoreDataTransactionEntity> = CoreDataTransactionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", transaction.id)
        
        do {
            let entities = try context.fetch(request)
            if let entity = entities.first {
                entity.updateFromModel(transaction)
                try context.save()
                return true
            }
            return false
        } catch {
            print("Failed to update transaction: \(error)")
            return false
        }
    }
    
    func deleteTransaction(id: Int) async -> Bool {
        let request: NSFetchRequest<CoreDataTransactionEntity> = CoreDataTransactionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            let entities = try context.fetch(request)
            if let entity = entities.first {
                context.delete(entity)
                try context.save()
                return true
            }
            return false
        } catch {
            print("Failed to delete transaction: \(error)")
            return false
        }
    }
    
    func createTransaction(_ transaction: Transaction) async -> Bool {
        let request: NSFetchRequest<CoreDataTransactionEntity> = CoreDataTransactionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", transaction.id)
        
        do {
            let entities = try context.fetch(request)
            if entities.isEmpty {
                let entity = CoreDataTransactionEntity(context: context)
                entity.updateFromModel(transaction)
                try context.save()
                return true
            }
            return false
        } catch {
            print("Failed to create transaction: \(error)")
            return false
        }
    }
} 