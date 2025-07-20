//
//  TransactionsStorage.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 19.07.2025.
//

import Foundation

protocol TransactionsStorage {
    func getAllTransactions() async -> [Transaction]
        
    /// Изменить операцию по id
    /// - Parameter transaction: Обновленная операция
    /// - Returns: true если операция была успешно изменена, false если операция не найдена
    func updateTransaction(_ transaction: Transaction) async -> Bool
        
    /// Удалить операцию по id
    /// - Parameter id: ID операции для удаления
    /// - Returns: true если операция была успешно удалена, false если операция не найдена
    func deleteTransaction(id: Int) async -> Bool
        
    /// Создать новую операцию
    /// - Parameter transaction: Новая операция для создания
    /// - Returns: true если операция была успешно создана, false если операция с таким id уже существует
    func createTransaction(_ transaction: Transaction) async -> Bool

}
