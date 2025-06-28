//
//  AccountView.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 12.06.2025.
//

import SwiftUI

struct AccountView: View {
    @State private var account: BankAccount?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var isEditing = false

    
    private let bankAccountsService = BankAccountsService()
    private let currencyService = CurrencyService()
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Загрузка...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = errorMessage {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        Text("Ошибка")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text(errorMessage)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let account = account {
                    List {
                        Section {
                            HStack {
                                Text("Баланс")
                                Spacer()

                                    Text("\(NSDecimalNumber(decimal: account.balance).doubleValue, specifier: "%.2f") \(currencyService.getSymbol(for: account.currency))")
                                
                            }
                            .contentShape(Rectangle())
                        }
                        .listRowBackground(Color.accentColor)
                        
                        Section {
                            HStack {
                                Text("Валюта")
                                Spacer()
                                Text("\(currencyService.getSymbol(for: account.currency))")
                            }
                            .contentShape(Rectangle())
                        }
                        .listRowBackground(Color.accentColor.opacity(0.12))
                    }
                    .padding(.bottom)
                }
            }
            .navigationTitle("Мой счет")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Готово" : "Редактировать") {
                        if isEditing {
                            isEditing = false
                        } else {
                            isEditing = true
                        }
                    }
                }
            }
            .task {
                await loadAccount()
            }
        }
    }
    
    private func loadAccount() async {
        isLoading = true
        errorMessage = nil
        
        do {
            account = try await bankAccountsService.getAccount()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

#Preview {
    AccountView()
} 
