//
//  AccountBalanceService.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 19.07.2025.
//

import Foundation

final class AccountBalanceService {
    let bankAccountsService: BankAccountsService
    
    init(bankAccountsService: BankAccountsService) {
        self.bankAccountsService = bankAccountsService
    }
    
    /// Обновляет баланс счета при добавлении транзакции
    func updateBalanceForTransaction(_ transaction: Transaction) async throws {
        var account = try await bankAccountsService.getAccount(id: transaction.account.id)
        
        // Обновляем баланс в зависимости от направления транзакции
        switch transaction.category.direction {
        case .income:
            account.balance += transaction.amount
        case .outcome:
            account.balance -= transaction.amount
        case .all:
            // Для .all не изменяем баланс
            return
        }
        
        // Обновляем счет
        try await bankAccountsService.update(from: &account)
    }
    
    /// Откатывает баланс счета при удалении транзакции
    func rollbackBalanceForTransaction(_ transaction: Transaction) async throws {
        var account = try await bankAccountsService.getAccount(id: transaction.account.id)
        
        // Откатываем баланс в зависимости от направления транзакции
        switch transaction.category.direction {
        case .income:
            account.balance -= transaction.amount
        case .outcome:
            account.balance += transaction.amount
        case .all:
            // Для .all не изменяем баланс
            return
        }
        
        // Обновляем счет
        try await bankAccountsService.update(from: &account)
    }
} 