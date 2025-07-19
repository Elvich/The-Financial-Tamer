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
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Transaction.self
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
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
