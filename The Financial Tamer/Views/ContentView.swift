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
    
    @StateObject private var transactionsService = TransactionsService(networkClient: DefaultNetworkClient())
    @StateObject private var categoriesService = CategoriesService(networkClient: DefaultNetworkClient())
    @StateObject private var bankAccountsService = BankAccountsService(networkClient: DefaultNetworkClient())
    
    var body: some View {
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
                ErrorView()
            }
        }
    }
}

#Preview {
    ContentView()
}
