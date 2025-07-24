//
//  BankAccountsStorage.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 19.07.2025.
//

import Foundation

protocol BankAccountsStorage {
    /// Получить все счета
    ///  - Returns: массив счетов
    func getAllAccounts() async -> [BankAccount]
        
    /// Изменить счет по id
    /// - Parameter account: Обновленный счет
    /// - Returns: true если счет был успешно изменен, false если счет не найден
    func updateAccount(_ account: BankAccount) async -> Bool
        
    /// Удалить счет по id
    /// - Parameter id: ID счета для удаления
    /// - Returns: true если счет был успешно удален, false если счет не найден
    func deleteAccount(id: Int) async -> Bool
        
    /// Создать новый счет
    /// - Parameter account: Новый счет для создания
    /// - Returns: true если счет был успешно создан, false если счет с таким id уже существует
    func createAccount(_ account: BankAccount) async -> Bool
} 
