//
//  CategoriesService.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 12.06.2025.
//

import Foundation

final class CategoriesService {
    
    private let categories: [Category] = [
        Category(id: 0, name: "Маркет", emoji: "🚚", direction: .outcome),
        Category(id: 1, name: "ЗП", emoji: "💰", direction: .income),
        Category(id: 2, name: "ЯндексGO", emoji: "🚕", direction: .outcome),
        Category(id: 3, name: "Фриланс", emoji: "💳", direction: .income),
        Category(id: 4, name: "Помощь рядом", emoji: "💚", direction: .outcome)
    ]

    
    func categories() async -> [Category] {
        return categories
    }

    func categories(for direction: Direction) async -> [Category] {
        return categories.filter { $0.direction == direction }
    }
}
