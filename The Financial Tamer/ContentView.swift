//
//  ContentView.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 06.06.2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    
    var body: some View {
        TabView {
            Tab("Расходы", image: "Expenses") {
                ErrorView()
            }


            Tab("Доходы", image: "Income") {
                ErrorView()
            }
            
            
            Tab("Счет", image: "Account") {
                ErrorView()
            }
            
            
            Tab("Статьи", image: "Articles") {
                ErrorView()
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
