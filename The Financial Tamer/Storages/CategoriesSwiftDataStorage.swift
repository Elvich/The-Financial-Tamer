//
//  CategoriesSwiftDataStorage.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 19.07.2025.
//

import Foundation
import SwiftData
import SwiftUI
import _SwiftData_SwiftUI

final class CategoriesSwiftDataStorage: CategoriesStorage {
    
    @Query private var categories: [CategorySwiftDataEntity]
    @Environment(\.modelContext) private var context
    
    func getAllCategories() async -> [Category] {
        return categories.compactMap { $0.toModel() }
    }
    
    func updateCategory(_ category: Category) async -> Bool {
        if let existingEntity = categories.first(where: { $0.id == category.id }) {
            existingEntity.updateFromModel(category)
            return true
        }
        return false
    }
    
    func deleteCategory(id: Int) async -> Bool {
        guard let index = categories.firstIndex(where: { $0.id == id }) else {
            return false
        }
        
        context.delete(categories[index])
        return true
    }
    
    func createCategory(_ category: Category) async -> Bool {
        if categories.contains(where: { $0.id == category.id }) {
            return false
        }
        
        let entity = CategorySwiftDataEntity(from: category)
        context.insert(entity)
        return true
    }
    
    func saveCategories(_ categories: [Category]) async {
        // Удаляем все существующие категории
        for entity in self.categories {
            context.delete(entity)
        }
        
        // Добавляем новые категории
        for category in categories {
            let entity = CategorySwiftDataEntity(from: category)
            context.insert(entity)
        }
    }
} 