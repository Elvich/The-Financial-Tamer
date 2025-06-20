//
//  TransactionsListView.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 14.06.2025.
//

import SwiftUI

struct TransactionsListView: View {
    
    let direction: Direction
    var transactionService = TransactionsService()
    
    var body: some View {
        NavigationStack {
            VStack() {
                List{
                    totalRowView()
                    transactionsSection()
                }
                .padding(.bottom)
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink(destination: ErrorView()) {
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
    
    @ViewBuilder
    private func totalRowView() -> some View {
        let transactions = transactionService.getTransactions(direction)
        let totalAmount = transactions.reduce(Decimal.zero) { $0 + $1.amount }
        
        HStack() {
            Text("Всего")
            Spacer()
            Text("\(totalAmount) $")
        }
    }
    
    @ViewBuilder
    private func transactionsSection() -> some View {
        let transactions: [Transaction] = transactionService.getTransactions(direction)
        
        Section(header: Text("Операции")) {
            ForEach(transactions, id: \.self) { transition in
                NavigationLink(destination: ErrorView()) {
                    HStack {
                        Text("\(transition.category.emoji)    \(transition.category.name)")
                        Spacer()
                        Text("\(transition.amount) $")
                    }
                }
            }
        }
    }
}

#Preview {
    TransactionsListView(direction: .income)
}
