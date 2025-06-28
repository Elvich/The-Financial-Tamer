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
    private let currencyService = CurrencyService()
    
    let direction: Direction
    
    @ViewBuilder
    func totalRowView(startDate: Date = DateService().startOfDay(), endDate: Date =  DateService().endOfDay(), text:String = "Всего") -> some View {
        let transactions = transactionService.getTransactions(start: startDate, end: endDate, direction: direction)
        let totalAmount = transactions.reduce(Decimal.zero) { $0 + $1.amount }
        
        HStack() {
            Text(text)
            Spacer()
            Text("\(totalAmount) \(currencyService.getSymbol(for: transactions[0].account.currency))")
        }
    }
    
    
    
    @ViewBuilder
    func transactionsSection(startDate: Date = DateService().startOfDay(), endDate: Date =  DateService().endOfDay(), sortType: HistoryView.SortType = .date) -> some View {
        let transactions: [Transaction] = transactionService.getTransactions(start: startDate, end: endDate, direction: direction)
        
        let sortedTransactions = sortTransactions(transactions, sortType)
        
        Section(header: Text("Операции")) {
            ForEach(sortedTransactions, id: \.self) { transition in
                NavigationLink(destination: ErrorView()) {
                    HStack {
                        Text("\(transition.category.emoji)    \(transition.category.name)")
                        Spacer()
                        Text("\(transition.amount) \(currencyService.getSymbol(for: transition.account.currency))")
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
