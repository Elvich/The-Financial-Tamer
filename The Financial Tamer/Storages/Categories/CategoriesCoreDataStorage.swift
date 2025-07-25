//
//  CategoriesCoreDataStorage.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 19.07.2025.
//

import Foundation
import CoreData

final class CategoriesCoreDataStorage: CategoriesStorage {
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
    
    func getAllCategories() async -> [Category] {
        let request: NSFetchRequest<CoreDataCategoryEntity> = CoreDataCategoryEntity.fetchRequest()
        
        do {
            let entities = try context.fetch(request)
            return entities.compactMap { $0.toModel() }
        } catch {
            print("Failed to fetch categories: \(error)")
            return []
        }
    }
    
    func updateCategory(_ category: Category) async -> Bool {
        let request: NSFetchRequest<CoreDataCategoryEntity> = CoreDataCategoryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", category.id)
        
        do {
            let entities = try context.fetch(request)
            if let entity = entities.first {
                entity.updateFromModel(category)
                try context.save()
                return true
            }
            return false
        } catch {
            print("Failed to update category: \(error)")
            return false
        }
    }
    
    func deleteCategory(id: Int) async -> Bool {
        let request: NSFetchRequest<CoreDataCategoryEntity> = CoreDataCategoryEntity.fetchRequest()
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
            print("Failed to delete category: \(error)")
            return false
        }
    }
    
    func createCategory(_ category: Category) async -> Bool {
        let request: NSFetchRequest<CoreDataCategoryEntity> = CoreDataCategoryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", category.id)
        
        do {
            let entities = try context.fetch(request)
            if entities.isEmpty {
                let entity = CoreDataCategoryEntity(context: context)
                entity.updateFromModel(category)
                try context.save()
                return true
            }
            return false
        } catch {
            print("Failed to create category: \(error)")
            return false
        }
    }
    
    func saveCategories(_ categories: [Category]) async {
        // Удаляем все существующие категории
        let request: NSFetchRequest<CoreDataCategoryEntity> = CoreDataCategoryEntity.fetchRequest()
        do {
            let entities = try context.fetch(request)
            for entity in entities {
                context.delete(entity)
            }
            
            // Добавляем новые категории
            for category in categories {
                let entity = CoreDataCategoryEntity(context: context)
                entity.updateFromModel(category)
            }
            
            try context.save()
        } catch {
            print("Failed to save categories: \(error)")
        }
    }
} 