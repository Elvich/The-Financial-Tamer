//
//  BankAccountsCoreDataStorage.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 19.07.2025.
//

import Foundation
import CoreData

final class BankAccountsCoreDataStorage: BankAccountsStorage {
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
    
    func getAllAccounts() async -> [BankAccount] {
        let request: NSFetchRequest<CoreDataBankAccountEntity> = CoreDataBankAccountEntity.fetchRequest()
        
        do {
            let entities = try context.fetch(request)
            return entities.compactMap { $0.toModel() }
        } catch {
            print("Failed to fetch bank accounts: \(error)")
            return []
        }
    }
    
    func updateAccount(_ account: BankAccount) async -> Bool {
        let request: NSFetchRequest<CoreDataBankAccountEntity> = CoreDataBankAccountEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", account.id)
        
        do {
            let entities = try context.fetch(request)
            if let entity = entities.first {
                entity.updateFromModel(account)
                try context.save()
                return true
            }
            return false
        } catch {
            print("Failed to update bank account: \(error)")
            return false
        }
    }
    
    func deleteAccount(id: Int) async -> Bool {
        let request: NSFetchRequest<CoreDataBankAccountEntity> = CoreDataBankAccountEntity.fetchRequest()
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
            print("Failed to delete bank account: \(error)")
            return false
        }
    }
    
    func createAccount(_ account: BankAccount) async -> Bool {
        let request: NSFetchRequest<CoreDataBankAccountEntity> = CoreDataBankAccountEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", account.id)
        
        do {
            let entities = try context.fetch(request)
            if entities.isEmpty {
                let entity = CoreDataBankAccountEntity(context: context)
                entity.updateFromModel(account)
                try context.save()
                return true
            }
            return false
        } catch {
            print("Failed to create bank account: \(error)")
            return false
        }
    }
} 