//
//  TransactionsView.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 21.06.2025.
//

import SwiftUI

struct TransactionsView {
    
    let transactionService: TransactionsService = TransactionsService()
    
    @ViewBuilder
    private func transactionsSection(startDate: Date, endDate: Date, direction: Direction) -> some View {
        let transactions: [Transaction] = transactionService.getTransactions(start: startDate, end: endDate, direction: direction)
        
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
    
    @ViewBuilder
    private func transactionsSection(startDate: Date, endDate: Date, direction: Direction, sortType: SortType) -> some View {
        let transactions: [Transaction] = transactionService.getTransactions(start: startDate, end: endDate, direction: direction)
        
        let sortedTransactions = sortTransactions(transactions, sortType)
        
        Section(header: Text("Операции")) {
            ForEach(sortedTransactions, id: \.self) { transition in
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
    
    private func sortTransactions(_ transactions: [Transaction], _ sortType: SortType) -> [Transaction] {
        switch sortType {
            case .date:
                return transactions.sorted { $0.transactionDate > $1.transactionDate }
            case .amount:
                return transactions.sorted { $0.amount > $1.amount }
        }
    }
}

extension TransactionsView{
    enum SortType: String, CaseIterable {
        case date = "дате"
        case amount = "сумме"
    }
}
