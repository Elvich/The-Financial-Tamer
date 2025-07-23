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
    
    var appDependency = AppDependency()

    var body: some View {
        ZStack {
            TabView {
                Tab("Расходы", image: "Outcome") {
                    TransactionsListView(
                        direction: .outcome,
                        container: appDependency)
                }
                Tab("Доходы", image: "Income") {
                    TransactionsListView(
                        direction: .income,
                        container: appDependency)
                }
                Tab("Счет", image: "Account") {
                    AccountView(container: appDependency)
                }
                Tab("Статьи", image: "Articles") {
                    CategoryView(container: appDependency)
                }
                            Tab("Настройки", image: "Settings") {
                SettingsView(container: appDependency)
            }
            }
 
            // Оффлайн индикатор
            VStack {
                OfflineIndicatorView(container: appDependency )
                Spacer()
            }
        }
        .onAppear {
            appDependency.SetupServices(modelContext: modelContext)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            // Проверяем настройки при возвращении в приложение
            checkStorageSettings()
        }
    }
    
    private func checkStorageSettings() {
        // Проверяем, изменились ли настройки хранения
        let savedType = UserDefaults.standard.string(forKey: "StorageType") ?? StorageType.swiftData.rawValue
        let newStorageType = StorageType(rawValue: savedType) ?? .swiftData
    }
}

#Preview {
    ContentView()
}
