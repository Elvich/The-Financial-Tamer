//
//  ContentView.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 06.06.2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var transactionsService = TransactionsService()
    @StateObject private var categoriesService = CategoriesService()
    @StateObject private var bankAccountsService = BankAccountsService()
    
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
