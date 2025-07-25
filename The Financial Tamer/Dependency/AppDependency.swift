//
//  AppDependency.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 23.07.2025.
//

import Foundation
import SwiftData
import Combine

class AppDependency: ObservableObject, NetworkClientProtocol, NetworkStatusServiceProtocol, DateServiceProtocol, StorageManagerProtocol, TransactionsServiceProtocol, CurrencyServiceProtocol, CategoriesServiceProtocol, BankAccountsServiceProtocol, AppSettingsProtocol
{
    @Published var appSettings: AppSettings
    
    var categoriesService: CategoriesService
    
    var bankAccountsService: BankAccountsService
    
    var currencyService: CurrencyService
    
    var transactionsService: TransactionsService
    
    var storageManager: StorageManager
    
    var dateService: DateService
    
    var networkStatus: NetworkStatusService
    
    var networkClient: NetworkClient
    
    init(){
        let networkClient = DefaultNetworkClient()
        let networkStatus = NetworkStatusService()
        let dateService = DateService()
        let storageManager = StorageManager()
        let appSettings = AppSettings()
        
        // Создаем сервисы, используя локальные переменные (не self!)
        let transactionsService = TransactionsService(networkClient: networkClient, networkStatus: networkStatus)
        let categoriesService = CategoriesService(networkClient: networkClient)
        let currencyService = CurrencyService()
        let bankAccountsService = BankAccountsService(networkClient: networkClient)
        
        // Теперь инициализируем все stored properties
        self.networkClient = networkClient
        self.networkStatus = networkStatus
        self.dateService = dateService
        self.storageManager = storageManager
        self.appSettings = appSettings
        self.transactionsService = transactionsService
        self.categoriesService = categoriesService
        self.currencyService = currencyService
        self.bankAccountsService = bankAccountsService
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
