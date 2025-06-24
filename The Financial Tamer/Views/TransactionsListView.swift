//
//  TransactionsListView.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 14.06.2025.
//

import SwiftUI

struct TransactionsListView: View {
    
    let direction: Direction
    
    private var title: String {
        (direction == .outcome ? "Расходы" : "Доходы") + " сегодня"
    }
    
    var body: some View {
        NavigationStack {
            List {
                TransactionsView(direction: direction).totalRowView()
                TransactionsView(direction: direction).transactionsSection()
            }
            .padding(.bottom)
            .navigationTitle(title)
            .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink(destination: HistoryView(direction: direction)) {
                    Image(systemName: "clock")
                            .foregroundColor(.purple)
                    }
                }
            }
        }
    }
}

#Preview {
    TransactionsListView(direction: .income)
}
