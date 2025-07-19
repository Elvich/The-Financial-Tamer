//
//  CategorySwiftDataEntity.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 19.07.2025.
//

import Foundation
import SwiftData

@Model
final class CategorySwiftDataEntity {
    var id: Int32
    var name: String
    var emoji: String
    var direction: String
    
    init(from category: Category) {
        self.id = Int32(category.id)
        self.name = category.name
        self.emoji = String(category.emoji)
        self.direction = category.direction.rawValue
    }
    
    func toModel() -> Category? {
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