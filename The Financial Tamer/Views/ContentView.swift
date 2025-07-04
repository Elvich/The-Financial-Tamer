//
//  ContentView.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 06.06.2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {    
    var body: some View {
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
                ErrorView()
            }
        }
        

    }
    
}

#Preview {
    ContentView()
}
