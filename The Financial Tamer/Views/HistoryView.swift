//
//  HistoryView.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 20.06.2025.
//

import SwiftUI

struct HistoryView: View {
    
    @EnvironmentObject var appDependency: AppDependency
    
    let direction: Direction

    @State private var sortType: SortType = .date
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var showingEditTransaction = false
    @State private var selectedTransaction: Transaction?
    @State private var totalAmount: Decimal = 0
    
    @State private var transactions: [Transaction] = []

    private let dateService = DateService()
    
    init(direction: Direction) {
        self.direction = direction
        

        let monthAgo = dateService.calendar.date(
            byAdding: .month,
            value: -1,
            to: dateService.now
        )!

        _startDate = State(initialValue: dateService.startOfDay(date: monthAgo))
        _endDate = State(initialValue: dateService.endOfDay())
    }

    var body: some View {
        NavigationStack {
            VStack{
                transactionsSettingsSection()
                    .padding(12)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                
                List {
                    //transactionsSettingsSection()
                    Section(header: Text("Операции")) {
                        ForEach(transactions) { transaction in
                            Button(action: {
                                selectedTransaction = transaction
                                showingEditTransaction = true
                            }) {
                                HStack {
                                    Text("\(transaction.category.emoji)    \(transaction.category.name)")
                                    Spacer()
                                    Text("\(transaction.amount) RUB")
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .task{
                    Task{
                        transactions = await filteredTransactions()
                        totalAmount = transactions.reduce(Decimal.zero) { $0 + $1.amount }
                    }
                }
                .refreshable{
                    Task{
                        transactions = await filteredTransactions()
                        totalAmount = transactions.reduce(Decimal.zero) { $0 + $1.amount }
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .padding(.bottom)
        }
        .navigationTitle("Моя история")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink(destination: AnalysisViewControllerWrapper(direction: direction)
                    .navigationTitle("Анализ")
                    .navigationBarTitleDisplayMode(.large)
                    .toolbarBackground(Color(.systemGroupedBackground), for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
                ) {
                    Image(systemName: "document")
                        .foregroundColor(.purple)
                }
            }
        }
        .sheet(item: $selectedTransaction) { transaction in
            TransactionEditView(
                mode: .edit,
                direction: direction,
                transaction: transaction
            )
        }
    }

    @ViewBuilder
    private func transactionsSettingsSection() -> some View {

        VStack{
            HStack {
                Text("Начало")
                Spacer()
                
                DatePicker("", selection: $startDate, displayedComponents: .date)
                    .labelsHidden()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.accentColor.opacity(0.12))
                    )
                    .foregroundColor(.primary)
                    .onChange(of: startDate) { _, newDate in
                        let normalizedStart = dateService.startOfDay(date: newDate)
                        if normalizedStart > endDate {
                            endDate = dateService.endOfDay(date: normalizedStart)
                        }
                        startDate = normalizedStart
                    }
            }
            
            HStack {
                Text("Конец")
                Spacer()
                DatePicker("", selection: $endDate, displayedComponents: .date)
                    .labelsHidden()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.accentColor.opacity(0.12))
                    )
                    .foregroundColor(.primary)
                    .onChange(of: endDate) { _, newDate in
                        let normalizedEnd = dateService.endOfDay(date: newDate)
                        if normalizedEnd < startDate {
                            startDate = dateService.startOfDay(date: normalizedEnd)
                        }
                        endDate = normalizedEnd
                    }
            }
            
            HStack {
                Text("Cортировать по ")
                Spacer()
                Picker("", selection: $sortType) {
                    ForEach(SortType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.palette)
            }
            
            HStack {
                Text("Всего")
                Spacer()
                if let first = transactions.first {
                    Text("\( totalAmount ) \(appDependency.currencyService.getSymbol(for: first.account.currency))")
                } else {
                    Text("\(totalAmount)")
                }
            }
        }
    }

    private func filteredTransactions() async -> [Transaction] {
        
        let filtered = try! await appDependency.transactionsService.getTransactions(start: startDate, end: endDate, direction: direction, hardRefresh: true).filter {
                $0.category.direction == direction &&
                $0.transactionDate >= startDate &&
                $0.transactionDate <= endDate
        }
        switch sortType {
        case .date:
            return filtered.sorted { $0.transactionDate > $1.transactionDate }
        case .amount:
            return filtered.sorted { $0.amount > $1.amount }
        }
    }
}

extension HistoryView {
    enum SortType: String, CaseIterable {
        case date = "дате"
        case amount = "сумме"
    }
}

#Preview {
    HistoryView(direction: .outcome)
        .environmentObject(AppDependency())
}
