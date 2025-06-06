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
            }


            Tab("Доходы", image: "Income") {
            }
            
            
            Tab("Счет", image: "Account") {
            }
            
            
            Tab("Статьи", image: "Articles") {
            }


            Tab("Настройки", image: "Settings") {
            }
        }
    }
    
}

#Preview {
    ContentView()
}
