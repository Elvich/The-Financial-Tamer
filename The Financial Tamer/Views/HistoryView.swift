//
//  HistoryView.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 20.06.2025.
//

import SwiftUI

struct HistoryView: View {
    
    let direction: Direction
    var transactionService = TransactionsService()
    
    @State private var startDate = Date()
    @State private var endDate = Date()
    
    private let calendar = Calendar.current

    init(direction: Direction) {
        self.direction = direction
        
        let now = Date()
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: now)!
                
        let monthAgo = calendar.date(byAdding: .month, value: -1, to: now)!
                
        let startOfDayMonthAgo = calendar.startOfDay(for: monthAgo)
            
        _startDate = State(initialValue: startOfDayMonthAgo)
        _endDate = State(initialValue: endOfDay)
    }
    
    var body: some View {
        NavigationStack{
            VStack{
                List{
                    transactionsSettingsSection()
                    transactionsSection()
                }
            }
        }
        .navigationTitle("Моя история")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink(destination: ErrorView()) {
                    Image(systemName: "document")
                        .foregroundColor(.purple)
                }
            }
        }
    }
    
    @ViewBuilder
    private func transactionsSettingsSection() -> some View {
        let transactions = transactionService.getTransactions(start: startDate, end: endDate, direction: direction)
        let totalAmount = transactions.reduce(Decimal.zero) { $0 + $1.amount }
              
        HStack() {
            Text("Начало")
            Spacer()
            DatePicker("", selection: $startDate, displayedComponents: .date)
        }
        
        HStack() {
            Text("Конец")
            Spacer()
            DatePicker("", selection: $endDate, displayedComponents: .hourAndMinute)
        }
        
        HStack() {
            Text("Сумма")
            Spacer()
            Text("\(totalAmount) $")
        }
    }
    
    @ViewBuilder
    private func transactionsSection() -> some View {
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

}

#Preview {
    HistoryView(direction: .outcome)
}
