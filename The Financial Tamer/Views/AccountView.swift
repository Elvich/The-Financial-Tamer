//
//  AccountView.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 12.06.2025.
//

import SwiftUI
import UIKit

struct AccountView: View {
    // MARK: - Dependencies
    @EnvironmentObject var appDependency: AppDependency
    
    // MARK: - Properties
    @State private var account: BankAccount?
    
    // MARK: - UI State
    @State private var isEditing = false
    @State private var newAccount: BankAccount?
    @State private var editingBalance = ""
    @State private var isBalanceHidden = false
    @State private var balanceSpoiler = false
    @State private var showCurrencyDialog = false
    @State private var isLoading = false
    @State private var errorMessage: String?
        
    
    // MARK: - Constants
    private enum Constants {
        static let animationDuration: Double = 0.3
        static let balanceFormat = "%.2f"
        static let balancePlaceholder = "0.00"
        static let balanceHeight: CGFloat = 24
        static let cornerRadius: CGFloat = 12
        static let horizontalPadding: CGFloat = 16
        static let verticalPadding: CGFloat = 16
        static let spacing: CGFloat = 8
        static let balanceSpacing: CGFloat = 4
        static let currencySpacing: CGFloat = 8
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            if let account = account {
                accountContent(for: account)
            } else if isLoading {
                loadingView
            } else if let errorMessage = errorMessage {
                errorView(message: errorMessage)
            } else {
                emptyView
            }
        }
        .background(shakeDetector)
        .task {
            await loadAccount()
        }
    }
}

// MARK: - View Components
private extension AccountView {
    
    var shakeDetector: some View {
        ShakeRepresentable(isActive: !isEditing) {
            toggleBalanceVisibility()
        }
    }
    
    func accountContent(for account: BankAccount) -> some View {
        
        let chartView = BalanceHistoryChartView()
        
        return ScrollView{
            VStack(spacing: Constants.spacing) {
                balanceSection(for: account)
                currencySection(for: account)
                chartView
                Spacer()
            }
        }
        .refreshable {
            Task{
                await loadAccount(hardRefresh: true)
            }
        }
        .background(Color(.systemGroupedBackground))
        .padding(.bottom)
        .navigationTitle("Мой счет")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                editButton
            }
        }
        .gesture(
            DragGesture()
                .onEnded { _ in hideKeyboard() }
        )
        .onTapGesture {
            hideKeyboard()
        }
        .disabled(isLoading)
        .opacity(isLoading ? 0.6 : 1.0)
    }
    
    var editButton: some View {
        Button(action: {
            changeState()
        }) {
            HStack(spacing: 4) {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                }
                Text(isEditing ? "Готово" : "Редактировать")
            }
        }
        .foregroundColor(.purple)
        .disabled(isLoading)
    }
    
    var loadingView: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.5)
            Text("Загрузка...")
                .foregroundColor(.secondary)
                .padding(.top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)
            
            Text("Ошибка")
                .font(.headline)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Повторить") {
                Task {
                    await loadAccount()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    var emptyView: some View {
        VStack {
            Text("Нет данных")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    func balanceSection(for account: BankAccount) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text("Баланс")
                Spacer()
                if isEditing {
                    balanceEditView
                } else {
                    balanceDisplayView(for: account)
                }
            }
            .padding(Constants.verticalPadding)
            .background(Color.accentColor)
            .cornerRadius(Constants.cornerRadius)
            .padding(.horizontal, Constants.horizontalPadding)
        }
    }
    
    var balanceEditView: some View {
        HStack(spacing: Constants.currencySpacing) {
            balanceTextField
            pasteButton
        }
    }
    
    var balanceTextField: some View {
        TextField(Constants.balancePlaceholder, text: $editingBalance)
            .keyboardType(.decimalPad)
            .multilineTextAlignment(.trailing)
            .onAppear {
                editingBalance = formattedBalanceString()
            }
            .onChange(of: editingBalance) { _, newValue in
                editingBalance = filterBalanceInput(newValue)
                updateNewAccountBalance(editingBalance)
            }
            .onSubmit {
                hideKeyboard()
            }
    }
    
    var pasteButton: some View {
        Button(action: pasteBalance) {
            Image(systemName: "doc.on.clipboard")
        }
    }
    
    func balanceDisplayView(for account: BankAccount) -> some View {
        let balanceValue = NSDecimalNumber(decimal: account.balance).doubleValue
        let balanceString = String(format: Constants.balanceFormat, balanceValue)
        let currencySymbol = appDependency.currencyService.getSymbol(for: account.currency)
        
        return ZStack {
            if isBalanceHidden {
                hiddenBalanceView
            } else {
                visibleBalanceView(balance: balanceString, currency: currencySymbol)
            }
        }
        .frame(height: Constants.balanceHeight)
        .onTapGesture {
            toggleBalanceVisibility()
        }
    }
    
    var hiddenBalanceView: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(Color.gray.opacity(0.3))
            .frame(height: Constants.balanceHeight)
            .overlay(
                Text("••••••")
                    .foregroundColor(.gray)
                    .opacity(balanceSpoiler ? 1 : 0)
                    .animation(.easeInOut, value: balanceSpoiler)
            )
            .onAppear {
                withAnimation(.easeInOut(duration: Constants.animationDuration)) {
                    balanceSpoiler = true
                }
            }
    }
    
    func visibleBalanceView(balance: String, currency: String) -> some View {
        HStack(spacing: Constants.balanceSpacing) {
            Text(balance)
            Text(currency)
        }
        .transition(.opacity)
    }
    
    func currencySection(for account: BankAccount) -> some View {
        VStack(spacing: 0) {
            Button(action: {
                if isEditing {
                    showCurrencyDialog = true
                }
            }) {
                currencyRow(for: account)
            }
            .buttonStyle(PlainButtonStyle())
            .confirmationDialog(
                "Валюта",
                isPresented: $showCurrencyDialog,
                titleVisibility: .visible
            ) {
                currencyOptions
            }
            .tint(.purple)
        }
    }
    
    func currencyRow(for account: BankAccount) -> some View {
        HStack {
            Text("Валюта")
            Spacer()
            if isEditing {
                if let newAccount = newAccount {
                    Text(appDependency.currencyService.getSymbol(for: newAccount.currency))
                }
            } else {
                Text(appDependency.currencyService.getSymbol(for: account.currency))
            }
        }
        .padding(Constants.verticalPadding)
        .background(Color.accentColor.opacity(0.12))
        .cornerRadius(Constants.cornerRadius)
        .padding(.horizontal, Constants.horizontalPadding)
    }
    
    var currencyOptions: some View {
        ForEach(Currency.allCases, id: \.self) { currency in
            Button("\(currency.displayName) \(appDependency.currencyService.getSymbol(for: currency.code))") {
                updateCurrency(to: currency.code)
            }
        }
    }
}

// MARK: - Business Logic
private extension AccountView {
    
    func loadAccount(hardRefresh: Bool = false) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            account = try await appDependency.bankAccountsService.getAccount(id: Utility.accountId ,hardRefresh: hardRefresh)
        } catch {
            print("Failed to load account: \(error.localizedDescription)")
            await MainActor.run {
                errorMessage = "Ошибка загрузки аккаунта: \(error.localizedDescription)"
            }
        }
        
        await MainActor.run {
            isLoading = false
        }
    }
    
    func changeState() {
        if isEditing {
            saveChanges()
        } else {
            startEditing()
        }
        isEditing.toggle()
    }
    
    func startEditing() {
        guard let account = account else {
            print("No account available for editing")
            return
        }
        
        newAccount = account
        editingBalance = String(
            format: Constants.balanceFormat,
            NSDecimalNumber(decimal: account.balance).doubleValue
        )
    }
    
    func saveChanges() {
        Task {
            await saveAccountChanges()
        }
        showCurrencyDialog = false
        hideKeyboard()
    }
    
    func saveAccountChanges() async {
        guard var newAccount = newAccount else { 
            print("No new account to save")
            return 
        }
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            // Проверяем, что у аккаунта есть валидный ID
            guard newAccount.id >= 0 else {
                print("Invalid account ID: \(newAccount.id)")
                await MainActor.run {
                    errorMessage = "Неверный ID аккаунта"
                }
                return
            }
            
            try await appDependency.bankAccountsService.update(from: &newAccount)
            await loadAccount()
        } catch {
            print("Failed to save account changes: \(error.localizedDescription)")
            await MainActor.run {
                errorMessage = "Ошибка сохранения: \(error.localizedDescription)"
            }
        }
        
        await MainActor.run {
            isLoading = false
        }
    }
    
    func updateNewAccountBalance(_ newValue: String) {
        guard var newAccount = newAccount,
              let doubleValue = Double(newValue) else { 
            print("Invalid balance value: \(newValue)")
            return 
        }
        
        newAccount.balance = Decimal(doubleValue)
        self.newAccount = newAccount
    }
    
    func updateCurrency(to code: String) {
        guard isEditing, var newAccount = newAccount else { 
            print("Cannot update currency: not in editing mode or no new account")
            return 
        }
        
        newAccount.currency = code
        self.newAccount = newAccount
    }
    
    func toggleBalanceVisibility() {
        withAnimation(.easeInOut(duration: Constants.animationDuration)) {
            isBalanceHidden.toggle()
        }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
    
    func pasteBalance() {
        guard let paste = UIPasteboard.general.string else { return }
        let filtered = paste.filter { "0123456789.,".contains($0) }
        editingBalance = filtered
        updateNewAccountBalance(filtered)
    }
    
    func formattedBalanceString() -> String {
        String(format: Constants.balanceFormat, 
               NSDecimalNumber(decimal: newAccount?.balance ?? 0).doubleValue)
    }
    
    func filterBalanceInput(_ input: String) -> String {
        let filtered = input.filter { "0123456789.,".contains($0) }
        let dotCount = filtered.filter { $0 == "." || $0 == "," }.count
        
        guard dotCount > 1,
              let firstIndex = filtered.firstIndex(where: { $0 == "." || $0 == "," }) else {
            return filtered
        }
        
        let distance = filtered.distance(from: filtered.startIndex, to: firstIndex)
        let prefix = filtered.prefix(distance + 1)
        let suffix = filtered.dropFirst(distance + 1)
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: "")
        
        return String(prefix) + suffix
    }
}

// MARK: - Currency Enum
private enum Currency: CaseIterable {
    case rub, usd, eur
    
    var code: String {
        switch self {
        case .rub: return "RUB"
        case .usd: return "USD"
        case .eur: return "EUR"
        }
    }
    
    var displayName: String {
        switch self {
        case .rub: return "Российский рубль"
        case .usd: return "Американский доллар"
        case .eur: return "Евро"
        }
    }
}

// MARK: - Shake Gesture Support
struct ShakeRepresentable: UIViewRepresentable {
    let isActive: Bool
    let onShake: () -> Void
    
    func makeUIView(context: Context) -> UIView {
        let view = ShakeDetectorView()
        view.onShake = onShake
        view.isActive = isActive
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        guard let shakeView = uiView as? ShakeDetectorView else { return }
        
        shakeView.isActive = isActive
        if isActive {
            shakeView.ensureFirstResponder()
        } else {
            shakeView.resignFirstResponder()
        }
    }
}

// MARK: - ShakeDetectorView
private class ShakeDetectorView: UIView {
    var onShake: (() -> Void)?
    var isActive: Bool = false
    
    override var canBecomeFirstResponder: Bool {
        return isActive
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        guard motion == .motionShake && isActive else { return }
        onShake?()
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
            }
        }
    }
}

// MARK: - Preview
#Preview {
    AccountView()
        .environmentObject(AppDependency())
}
