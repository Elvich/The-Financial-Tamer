//
//  TransactionsListView.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 14.06.2025.
//

import SwiftUI

struct TransactionsListView: View {
    
    @EnvironmentObject var appDependency: AppDependency
    
    let direction: Direction
    
    
    @State private var showingCreateTransaction = false
    @State private var selectedTransaction: Transaction? = nil
    
    @State private var transactions: [Transaction] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var totalAmount: Decimal = 0
    
    init(direction: Direction){
        self.direction = direction
    }
    
    private var title: String {
        (direction == .outcome ? "Расходы" : "Доходы") + " сегодня"
    }
    
    var body: some View {
        NavigationStack {
            ZStack{
                VStack{
                    
                    HStack {
                        Text("Всего")
                        Spacer()
                        if let first = transactions.first {
                            Text("\(totalAmount) \(appDependency.currencyService.getSymbol(for: first.account.currency))")
                        } else {
                            Text("\(totalAmount)")
                        }
                    }
                    .padding(16)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                
                    
                    if isLoading {
                        ProgressView()
                        
                    } else if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    } else {
                        List {
                            transactionsSection
                        }
                    }
                }
                .background(Color(.systemGroupedBackground))
                .padding(.bottom)
                .navigationTitle(title)
                .task {
                    await loadTransactions()
                }
                .refreshable {
                    await loadTransactions(hardRefresh: true)
                }
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showingCreateTransaction = true
                        }) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(Color.accentColor)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .padding(.bottom)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink(
                        destination: HistoryView( direction: direction )
                    ) {
                        Image(systemName: "clock")
                            .foregroundColor(.purple)
                    }
                }
            }
            .sheet(isPresented: $showingCreateTransaction) {
                TransactionEditView(mode: .create, direction: direction, transaction: nil)
            }
            .sheet(item: $selectedTransaction) { transaction in
                TransactionEditView(
                    mode: .edit,
                    direction: direction,
                    transaction: transaction
                )
            }
        }
    }
    
    private func loadTransactions(hardRefresh: Bool = false) async {
        isLoading = true
        errorMessage = nil
        do {
            let start = DateService().startOfDay()
            let end = DateService().endOfDay()
            transactions = try await appDependency.transactionsService.getTransactions(start: start, end: end, direction: direction, hardRefresh: hardRefresh)
        } catch {
            errorMessage = "Ошибка загрузки: \(error.localizedDescription)"
        }
        isLoading = false
        totalAmount = transactions.reduce(Decimal.zero) { $0 + $1.amount }
    }
    
    private var transactionsSection: some View {
        Section(header: Text("Операции")) {
            ForEach(transactions) { transaction in
                Button(action: {
                    selectedTransaction = transaction
                }) {
                    HStack {
                        Text("\(transaction.category.emoji)    \(transaction.category.name)")
                        Spacer()
                        Text("\(transaction.amount) \(CurrencyService().getSymbol(for: transaction.account.currency))")
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

#Preview {
    TransactionsListView(direction: .income)
        .environmentObject(AppDependency())
}
