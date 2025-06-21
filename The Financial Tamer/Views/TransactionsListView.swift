//
//  TransactionsListView.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 14.06.2025.
//

import SwiftUI

struct TransactionsListView: View {
    
    let direction: Direction
    let transactionsView : TransactionsView
    
    init(direction: Direction) {
        self.direction = direction
        transactionsView = TransactionsView(direction: direction)
    }
    
    var body: some View {
        NavigationStack {
            VStack() {
                List{
                    transactionsView.totalRowView()
                    transactionsView.transactionsSection()
                }
                .padding(.bottom)
            }
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
    
    
    private var title: String {
        (direction == .outcome ? "Расходы" : "Доходы") + " сегодня"
    }
    
}

#Preview {
    TransactionsListView(direction: .income)
}
