//
//  CategoryEntity.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 19.07.2025.
//

import Foundation
import SwiftData

@Model
final class CategoryEntity {
    @Attribute(.unique) var id: Int
    var name: String
    var emoji: String
    var direction: String
    
    init(from category: Category) {
        self.id = category.id
        self.name = category.name
        self.emoji = String(category.emoji)
        self.direction = category.direction.rawValue
    }
    
    func toModel() -> Category {
        return Category(
            id: self.id,
            name: self.name,
            emoji: self.emoji.first ?? "📊",
            direction: Direction(rawValue: self.direction) ?? .outcome
        )
    }
    
    func updateFromModel(_ category: Category) {
        self.name = category.name
        self.emoji = String(category.emoji)
        self.direction = category.direction.rawValue
    }
} 