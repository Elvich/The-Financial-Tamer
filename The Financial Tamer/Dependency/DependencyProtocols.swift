//
//  DependencyProtocols.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 23.07.2025.
//

import Foundation

protocol NetworkClientProtocol {
    var networkClient: NetworkClient { get }
}

protocol NetworkStatusServiceProtocol {
    var networkStatus: NetworkStatusService { get }
}

protocol DateServiceProtocol{
    var dateService: DateService { get }
}

protocol StorageManagerProtocol {
    var storageManager: StorageManager { get }
}

protocol TransactionsServiceProtocol {
    var transactionsService: TransactionsService { get }
}

protocol CurrencyServiceProtocol {
    var currencyService: CurrencyService { get }
}

protocol CategoriesServiceProtocol {
    var categoriesService: CategoriesService { get }
}

protocol BankAccountsServiceProtocol {
    var bankAccountsService: BankAccountsService { get }
}

protocol AppSettingsProtocol{
    var appSettings: AppSettings { get }
}
