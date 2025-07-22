//
//  ContentView.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 06.06.2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @Environment(\.modelContext) private var modelContext: ModelContext
    @StateObject private var storageManager = StorageManager()
    @StateObject private var networkStatusService = NetworkStatusService()
    
    @StateObject private var transactionsService = TransactionsService(networkClient: DefaultNetworkClient())
    @StateObject private var categoriesService = CategoriesService(networkClient: DefaultNetworkClient())
    @StateObject private var bankAccountsService = BankAccountsService(networkClient: DefaultNetworkClient())
    
    var body: some View {
        ZStack {
            TabView {
                Tab("Расходы", image: "Outcome") {
                    TransactionsListView(
                        direction: .outcome,
                        transactionsService: transactionsService,
                        categoriesService: categoriesService,
                        bankAccountsService: bankAccountsService
                    )
                }
                Tab("Доходы", image: "Income") {
                    TransactionsListView(
                        direction: .income,
                        transactionsService: transactionsService,
                        categoriesService: categoriesService,
                        bankAccountsService: bankAccountsService
                    )
                }
                Tab("Счет", image: "Account") {
                    AccountView(bankAccountsService: bankAccountsService)
                }
                Tab("Статьи", image: "Articles") {
                    CategoryView(categoriesService: categoriesService)
                }
                            Tab("Настройки", image: "Settings") {
                SettingsView()
            }
            }
 
            // Оффлайн индикатор
            VStack {
                OfflineIndicatorView()
                Spacer()
            }
        }
        .onAppear {
            setupServices()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            // Проверяем настройки при возвращении в приложение
            checkStorageSettings()
        }
    }
    
    private func setupServices() {
        // Передаем modelContext в сервисы
        transactionsService.modelContext = modelContext
        //categoriesService.modelContext = modelContext
        bankAccountsService.modelContext = modelContext
        
        // Настраиваем AccountBalanceService
        transactionsService.setBankAccountsService(bankAccountsService)
    }
    
    private func checkStorageSettings() {
        // Проверяем, изменились ли настройки хранения
        let savedType = UserDefaults.standard.string(forKey: "StorageType") ?? StorageType.swiftData.rawValue
        let newStorageType = StorageType(rawValue: savedType) ?? .swiftData
        
        if storageManager.currentStorageType != newStorageType {
            storageManager.currentStorageType = newStorageType
            // Здесь можно добавить логику миграции данных
        }
    }
}

#Preview {
    ContentView()
}
