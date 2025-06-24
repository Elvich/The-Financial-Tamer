//
//  TransactionsView.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 21.06.2025.
//

import SwiftUI

struct TransactionsView {
    
    private let transactionService: TransactionsService = TransactionsService()
    private let dateService = DateService()
    
    let direction: Direction
    
    @ViewBuilder
    func totalRowView(text:String = "Всего") -> some View {
        let transactions = transactionService.getTransactions(direction)
        let totalAmount = transactions.reduce(Decimal.zero) { $0 + $1.amount }
        
        HStack() {
            Text(text)
            Spacer()
            Text("\(totalAmount) $")
        }
    }
    
    @ViewBuilder
    func transactionsSection() -> some View {
        
        let startDate: Date = dateService.startOfDay()
        let endDate: Date = dateService.endOfDay()
        
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
    func transactionsSection(startDate: Date, endDate: Date, sortType: HistoryView.SortType) -> some View {
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
    
    private func sortTransactions(_ transactions: [Transaction], _ sortType: HistoryView.SortType) -> [Transaction] {
        switch sortType {
            case .date:
                return transactions.sorted { $0.transactionDate > $1.transactionDate }
            case .amount:
                return transactions.sorted { $0.amount > $1.amount }
        }
    }
}
