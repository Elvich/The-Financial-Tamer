//
//  The_Financial_TamerApp.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 06.06.2025.
//

import SwiftUI
import SwiftData

@main
struct The_Financial_TamerApp: App {
    
    @StateObject var appDependency = AppDependency()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TransactionSwiftDataEntity.self,
            BankAccountSwiftDataEntity.self,
            CategorySwiftDataEntity.self,
            BackupTransactionActionEntity.self,
            BackupBankAccountActionEntity.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            SplashView()
                .environmentObject(appDependency)
        }
        .modelContainer(sharedModelContainer)
    }
}
