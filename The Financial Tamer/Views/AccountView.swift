//
//  AccountView.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 12.06.2025.
//

import SwiftUI

struct AccountView: View {
    @State private var account: BankAccount?

    @State private var isEditing = false
    @State private var newAccount: BankAccount?
    @State private var editingBalance = ""
    @State private var editingCurrency = ""
    @State private var isKeyboardVisible = false
    @State private var showCurrencyDialog = false

    private let bankAccountsService = BankAccountsService()
    private let currencyService = CurrencyService()

    var body: some View {
        NavigationView {
            if let account = account {
                List {
                    Section {
                        Button(action: {
                            if isEditing {

                            }
                        }) {
                            HStack {
                                Text("Баланс")
                                Spacer()
                                if isEditing {
                                    if let newAccount = newAccount {
                                        TextField("0.00", text: $editingBalance)
                                            .keyboardType(.decimalPad)
                                            .multilineTextAlignment(.trailing)
                                            .onAppear {
                                                editingBalance = String(
                                                    format: "%.2f",
                                                    NSDecimalNumber(
                                                        decimal: newAccount
                                                            .balance
                                                    ).doubleValue
                                                )
                                            }
                                            .onChange(of: editingBalance) {
                                                oldValue,
                                                newValue in
                                                updateNewAccountBalance(
                                                    newValue
                                                )
                                            }
                                            .onSubmit {
                                                hideKeyboard()
                                            }
                                            .onTapGesture {
                                                // Позволяет скрыть клавиатуру при тапе вне поля
                                            }
                                    }
                                } else {
                                    Text(
                                        "\(NSDecimalNumber(decimal: account.balance).doubleValue, specifier: "%.2f") \(currencyService.getSymbol(for: account.currency))"
                                    )
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .listRowBackground(Color.accentColor)

                    Section {
                        Button(action: {
                            if isEditing {
                                showCurrencyDialog = true
                            }
                        }) {
                            HStack {
                                Text("Валюта")
                                Spacer()
                                if isEditing {
                                    if let newAccount = newAccount {
                                        Text(
                                            "\(currencyService.getSymbol(for: newAccount.currency))"
                                        )
                                    }
                                } else {
                                    Text(
                                        "\(currencyService.getSymbol(for: account.currency))"
                                    )
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .confirmationDialog(
                            "Валюта",
                            isPresented: $showCurrencyDialog,
                            titleVisibility: .visible
                        ) {
                            ForEach(["RUB", "USD", "EUR"], id: \.self) { code in
                                let name =
                                    code == "RUB"
                                    ? "Российский рубль"
                                    : code == "USD"
                                        ? "Американский доллар" : "Евро"
                                let symbol = currencyService.getSymbol(
                                    for: code
                                )
                                Button("\(name) \(symbol)") {
                                    if isEditing, var newAccount = newAccount {
                                        newAccount.currency = code
                                        self.newAccount = newAccount
                                    }
                                }
                            }
                        }
                        .tint(.purple)
                    }
                    .listRowBackground(Color.accentColor.opacity(0.12))
                }
                .padding(.bottom)
                .navigationTitle("Мой счет")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(isEditing ? "Готово" : "Редактировать") {
                            changeState()
                        }
                        .foregroundColor(.purple)
                    }
                }
                .gesture(
                    DragGesture()
                        .onEnded { _ in
                            hideKeyboard()
                        }
                )
                .onTapGesture {
                    hideKeyboard()
                }
            }

        }
        .task {
            await loadAccount()
        }
    }

    private func loadAccount() async {
        do {
            account = try await bankAccountsService.getAccount()
        } catch {
            print(error.localizedDescription)
        }
    }

    private func changeState() {
        if isEditing {
            Task {
                if var newAccount = newAccount {
                    do {
                        try await bankAccountsService.update(from: &newAccount)
                        await loadAccount()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        } else {
            newAccount = account
            // Инициализируем поля редактирования
            if let account = account {
                editingBalance = String(
                    format: "%.2f",
                    NSDecimalNumber(decimal: account.balance).doubleValue
                )
                editingCurrency = account.currency
            }
        }

        isEditing = !isEditing
    }

    private func updateNewAccountBalance(_ newValue: String) {
        if var newAccount = newAccount {
            if let doubleValue = Double(newValue) {
                newAccount.balance = Decimal(doubleValue)
                self.newAccount = newAccount
            }
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
        isKeyboardVisible = false
    }

}

#Preview {
    AccountView()
}
