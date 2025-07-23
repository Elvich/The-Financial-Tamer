//
//  CategoriesService.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 12.06.2025.
//

import Foundation
import SwiftUI
import SwiftData

final class CategoriesService: ObservableObject {
    private let networkClient: NetworkClient
    private let categoriesStorage = CategoriesSwiftDataStorage()
    @Published private(set) var categories: [Category] = []
    
    @Environment(\.modelContext) private var  modelContext: ModelContext
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func fetchCategories() async throws -> [Category] {
        let raw = try await networkClient.request(
            endpoint: "categories",
            method: .get,
            queryItems: nil,
            body: nil,
            headers: nil
        )
        guard let array = raw as? [Any] else {
            throw NSError(domain: "CategoriesService", code: 2, userInfo: [
                NSLocalizedDescriptionKey: "Unexpected raw data format"])
        }
        let categories = try await withThrowingTaskGroup(of: Category?.self) { group in
            for obj in array {
                group.addTask {
                    Category.parse(jsonObject: obj)
                }
            }
            return try await group.reduce(into: [Category]()) { result, category in
                if let category = category {
                    result.append(category)
                }
            }
        }
        
        // Сохраняем в локальное хранилище
        await categoriesStorage.saveCategories(categories)
        
        await MainActor.run {
            self.categories = categories
        }
        return categories
    }

    func categories(for direction: Direction = .all, hardRefresh: Bool = false) async throws -> [Category] {
        if categories.isEmpty || hardRefresh {
            categories = try await fetchCategories()
        } else {
            // Загружаем из локального хранилища
            let localCategories = await categoriesStorage.getAllCategories()
            await MainActor.run {
                self.categories = localCategories
            }
        }
        
        return direction != .all ? categories.filter { $0.direction == direction } : categories
    }
}
