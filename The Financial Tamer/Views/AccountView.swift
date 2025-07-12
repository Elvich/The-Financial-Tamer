//
//  AccountView.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 12.06.2025.
//

import SwiftUI
import UIKit

struct AccountView: View {
    @ObservedObject var bankAccountsService: BankAccountsService
    @State private var account: BankAccount?

    @State private var isEditing = false
    @State private var newAccount: BankAccount?
    @State private var editingBalance = ""
    @State private var editingCurrency = ""
    @State private var isKeyboardVisible = false
    @State private var isBalanceHidden = false
    @State private var balanceSpoiler = false
    @State private var showCurrencyDialog = false

    private let currencyService = CurrencyService()

    var body: some View {
        ZStack {
            mainBody
        }
        .background(
            ShakeRepresentable(isActive: !isEditing) {
                print("Shake detected in main view!") // Отладочная информация
                withAnimation(.easeInOut(duration: 0.3)) {
                    isBalanceHidden.toggle()
                }
            }
        )
        .onAppear {
            // Убеждаемся, что shake detector активен только в режиме просмотра
            if !isEditing {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    print("View appeared in view mode, shake detector should be active")
                }
            }
        }
    }

    private var mainBody: some View {
        NavigationStack {
            if let account = account {
                List {
                    Section {
                        HStack {
                            Text("Баланс")
                            Spacer()
                            if isEditing {
                                HStack(spacing: 8) {
                                    TextField("0.00", text: $editingBalance)
                                        .keyboardType(.decimalPad)
                                        .multilineTextAlignment(.trailing)
                                        .onAppear {
                                            editingBalance = formattedBalanceString()
                                        }
                                        .onChange(of: editingBalance) { oldValue, newValue in
                                            editingBalance = filterBalanceInput(newValue)
                                            updateNewAccountBalance(editingBalance)
                                        }
                                        .onSubmit {
                                            hideKeyboard()
                                        }
                                    Button(action: {
                                        if let paste = UIPasteboard.general.string {
                                            let filtered = paste.filter { "0123456789.,".contains($0) }
                                            editingBalance = filtered
                                            updateNewAccountBalance(filtered)
                                        }
                                    }) {
                                        Image(systemName: "doc.on.clipboard")
                                    }
                                }
                            } else {
                                let balanceValue = NSDecimalNumber(decimal: account.balance).doubleValue
                                let balanceString = String(format: "%.2f", balanceValue)
                                let currencySymbol = currencyService.getSymbol(for: account.currency)
                                ZStack {
                                    if isBalanceHidden {
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(height: 24)
                                            .overlay(
                                                Text("••••••")
                                                    .foregroundColor(.gray)
                                                    .opacity(balanceSpoiler ? 1 : 0)
                                                    .animation(.easeInOut, value: balanceSpoiler)
                                            )
                                            .onAppear {
                                                withAnimation(.easeInOut(duration: 0.3)) {
                                                    balanceSpoiler = true
                                                }
                                            }
                                    } else {
                                        HStack(spacing: 4) {
                                            Text(balanceString)
                                            Text(currencySymbol)
                                        }
                                        .transition(.opacity)
                                    }
                                }
                                .frame(height: 24)
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        isBalanceHidden.toggle()
                                    }
                                }
                            }
                        }
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
                                        let symbol = currencyService.getSymbol(for: newAccount.currency)
                                        Text(symbol)
                                    }
                                } else {
                                    let symbol = currencyService.getSymbol(for: account.currency)
                                    Text(symbol)
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

    fileprivate func pullToRefresh() {
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
    }
    
    private func changeState() {
        if isEditing {
            pullToRefresh()
            showCurrencyDialog = false
            hideKeyboard()
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

    private func formattedBalanceString() -> String {
        String(format: "%.2f", NSDecimalNumber(decimal: newAccount?.balance ?? 0).doubleValue)
    }
    
    private func filterBalanceInput(_ input: String) -> String {
        let filtered = input.filter { "0123456789.,".contains($0) }
        let dotCount = filtered.filter { $0 == "." || $0 == "," }.count
        if dotCount > 1, let firstIndex = filtered.firstIndex(where: { $0 == "." || $0 == "," }) {
            let distance = filtered.distance(from: filtered.startIndex, to: firstIndex)
            let prefix = filtered.prefix(distance + 1)
            let suffix = filtered.dropFirst(distance + 1).replacingOccurrences(of: ".", with: "").replacingOccurrences(of: ",", with: "")
            return String(prefix) + suffix
        }
        return filtered
    }

}

#Preview {
    AccountView(bankAccountsService: BankAccountsService())
}

// MARK: - Shake gesture support for SwiftUI
struct ShakeRepresentable: UIViewRepresentable {
    var isActive: Bool
    var onShake: () -> Void
    
    func makeUIView(context: Context) -> UIView {
        let view = ShakeDetectorView()
        view.onShake = onShake
        view.isActive = isActive
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Убеждаемся, что view остается firstResponder только когда активно
        if let shakeView = uiView as? ShakeDetectorView {
            shakeView.isActive = isActive
            if isActive {
                shakeView.ensureFirstResponder()
            } else {
                shakeView.resignFirstResponder()
            }
        }
    }
    
    class ShakeDetectorView: UIView {
        var onShake: (() -> Void)?
        var isActive: Bool = false
        
        override var canBecomeFirstResponder: Bool {
            return isActive
        }
        
        override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
            if motion == .motionShake && isActive {
                print("Shake detected in ShakeDetectorView!") // Отладочная информация
                onShake?()
            }
        }
        
        override func didMoveToWindow() {
            super.didMoveToWindow()
            if isActive {
                ensureFirstResponder()
            }
        }
        
        func ensureFirstResponder() {
            guard isActive else { return }
            DispatchQueue.main.async {
                if !self.isFirstResponder {
                    self.becomeFirstResponder()
                    print("ShakeDetectorView became first responder (view mode)")
                }
            }
        }
    }
}
