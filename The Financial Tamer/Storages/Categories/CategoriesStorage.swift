//
//  CategoriesStorage.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 19.07.2025.
//

import Foundation

protocol CategoriesStorage {
    func getAllCategories() async -> [Category]
        
    /// Изменить категорию по id
    /// - Parameter category: Обновленная категория
    /// - Returns: true если категория была успешно изменена, false если категория не найдена
    func updateCategory(_ category: Category) async -> Bool
        
    /// Удалить категорию по id
    /// - Parameter id: ID категории для удаления
    /// - Returns: true если категория была успешно удалена, false если категория не найдена
    func deleteCategory(id: Int) async -> Bool
        
    /// Создать новую категорию
    /// - Parameter category: Новая категория для создания
    /// - Returns: true если категория была успешно создана, false если категория с таким id уже существует
    func createCategory(_ category: Category) async -> Bool
    
    /// Сохранить все категории
    /// - Parameter categories: Массив категорий для сохранения
    func saveCategories(_ categories: [Category]) async
} 