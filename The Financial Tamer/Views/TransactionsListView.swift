//
//  TransactionsListView.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 14.06.2025.
//

import SwiftUI

struct TransactionsListView: View {
    let direction: Direction
    @ObservedObject var transactionsService: TransactionsService
    let categoriesService: CategoriesService
    let bankAccountsService: BankAccountsService
    @State private var showingCreateTransaction = false
    @State private var selectedTransaction: Transaction? = nil
    
    private var title: String {
        (direction == .outcome ? "Расходы" : "Доходы") + " сегодня"
    }
    
    var body: some View {
        NavigationStack {
            VStack{
                TransactionsView(transactionService: transactionsService, direction: direction).totalRowView()                    
                    .padding(16)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                
                
                List {
                    transactionsSection
                }
            }
            .background(Color(.systemGroupedBackground))
            .padding(.bottom)
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink(
                        destination: HistoryView(
                            direction: direction,
                            transactionsService: transactionsService,
                            categoriesService: categoriesService,
                            bankAccountsService: bankAccountsService
                        )
                    ) {
                        Image(systemName: "clock")
                            .foregroundColor(.purple)
                    }
                }
            }
            .overlay(
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
            )
            .sheet(isPresented: $showingCreateTransaction) {
                TransactionEditView(mode: .create, direction: direction, transaction: nil, transactionsService: transactionsService, categoriesService: categoriesService, bankAccountsService: bankAccountsService)
            }
            .sheet(item: $selectedTransaction) { transaction in
                TransactionEditView(
                    mode: .edit,
                    direction: direction,
                    transaction: transaction,
                    transactionsService: transactionsService,
                    categoriesService: categoriesService,
                    bankAccountsService: bankAccountsService
                )
            }
        }
    }
    
    private var filteredTransactions: [Transaction] {
        transactionsService.transactions.filter { $0.category.direction == direction }
    }
    
    private var transactionsSection: some View {
        return Section(header: Text("Операции")) {
            ForEach(filteredTransactions) { transaction in
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
    TransactionsListView(
        direction: .income,
        transactionsService: TransactionsService(),
        categoriesService: CategoriesService(networkClient: DefaultNetworkClient()),
        bankAccountsService: BankAccountsService(networkClient: DefaultNetworkClient())
    )
}
