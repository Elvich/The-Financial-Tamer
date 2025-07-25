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
    @EnvironmentObject var appDependency: AppDependency
    
    var body: some View {
        ZStack {
            TabView {
                Tab("Расходы", image: "Outcome") {
                    TransactionsListView(direction: .outcome)
                }
                Tab("Доходы", image: "Income") {
                    TransactionsListView(direction: .income)
                }
                Tab("Счет", image: "Account") {
                    AccountView()
                }
                Tab("Статьи", image: "Articles") {
                    CategoryView()
                }
                Tab("Настройки", image: "Settings") {
                    SettingsView()
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
        .preferredColorScheme(colorScheme)
    }
    
    private var colorScheme: ColorScheme? {
        switch appDependency.appSettings.appTheme {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
    
    private func checkStorageSettings() {
        // Проверяем, изменились ли настройки хранения
        let savedType = UserDefaults.standard.string(forKey: "StorageType") ?? StorageType.swiftData.rawValue
        _ = StorageType(rawValue: savedType) ?? .swiftData
    }
}

#Preview {
    ContentView()
        .environmentObject(AppDependency())
}
