//
//  CategoryEntity.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 19.07.2025.
//

import Foundation
import CoreData

extension CoreDataCategoryEntity {
    func toModel() -> Category? {
        guard let name = name,
              let emoji = emoji,
              let direction = direction else {
            return nil
        }
        
        return Category(
            id: Int(id),
            name: name,
            emoji: emoji.first ?? "📊",
            direction: Direction(rawValue: direction) ?? .outcome
        )
    }
    
    func updateFromModel(_ category: Category) {
        self.id = Int32(category.id)
        self.name = category.name
        self.emoji = String(category.emoji)
        self.direction = category.direction.rawValue
    }
} 