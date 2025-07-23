//
//  AppDependency.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 23.07.2025.
//

import Foundation
import SwiftData

struct AppDependency: NetworkClientProtocol, NetworkStatusServiceProtocol, DateServiceProtocol, StorageManagerProtocol, TransactionsServiceProtocol, CurrencyServiceProtocol, CategoriesServiceProtocol, BankAccountsServiceProtocol
{
    var categoriesService: CategoriesService
    
    var bankAccountsService: BankAccountsService
    
    var currencyService: CurrencyService
    
    var transactionsService: TransactionsService
    
    var storageManage: StorageManager
    
    var dateService: DateService
    
    var networkStatus: NetworkStatusService
    
    var networkClient: NetworkClient
    
    init(){
        networkClient = DefaultNetworkClient()
        networkStatus = NetworkStatusService()
        dateService = DateService()
        storageManage = StorageManager()
        
        transactionsService = TransactionsService(networkClient: networkClient, networkStatus: networkStatus)
        categoriesService = CategoriesService(networkClient: networkClient)
        currencyService = CurrencyService()
        bankAccountsService = BankAccountsService(networkClient: networkClient)
    }
}

extension AppDependency {
    func SetupServices(modelContext: ModelContext) {
        // Передаем modelContext в сервисы
        transactionsService.modelContext = modelContext
        bankAccountsService.modelContext = modelContext
        
        // Настраиваем AccountBalanceService
        transactionsService.setBankAccountsService(bankAccountsService)
    }
}
