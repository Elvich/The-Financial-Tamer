//
//  TransactionEditView.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 21.06.2025.
//

import SwiftUI

struct TransactionEditView: View {
    @Environment(\.dismiss) private var dismiss
    
    let mode: EditMode
    let direction: Direction
    let transaction: Transaction?
    @ObservedObject var transactionsService: TransactionsService
    let categoriesService: CategoriesService
    let bankAccountsService: BankAccountsService
    private let dateService = DateService()
    private let currencyService = CurrencyService()
    
    @State private var selectedCategory: Category?
    @State private var amount: String = ""
    @State private var transactionDate: Date = Date()
    @State private var comment: String = ""
    @State private var showingCategoryPicker = false
    @State private var availableCategories: [Category] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @FocusState private var amountFieldFocused: Bool
    
    private var isCreateMode: Bool { mode == .create }
    private var title: String {
        if direction == .outcome { return "Мои Расходы" }
        else { return "Мои Доходы" }
    }
    private var saveButtonTitle: String { isCreateMode ? "Создать" : "Сохранить" }
    private var canSave: Bool { !amount.isEmpty && selectedCategory != nil }
    private var currencySymbol: String { currencyService.getSymbol(for: "RUB") }
    
    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()
            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Button("Отмена") { dismiss() }
                        .foregroundColor(.accentColor)
                        .font(.system(size: 17, weight: .regular))
                    Spacer()
                    Button(saveButtonTitle) { saveTransaction() }
                        .foregroundColor(.accentColor)
                        .font(.system(size: 17, weight: .semibold))
                        .disabled(!canSave || isLoading)
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                // Title
                HStack {
                    Text(title)
                        .font(.system(size: 32, weight: .bold))
                        .padding(.top, 8)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
                
                // White card with fields
                VStack(spacing: 0) {
                    // Статья
                    HStack {
                        Text("Статья")
                            .font(.system(size: 17, weight: .regular))
                        Spacer()
                        Button(action: {
                            if !availableCategories.isEmpty {
                                showingCategoryPicker = true
                            }
                        }) {
                            HStack(spacing: 4) {
                                if let category = selectedCategory {
                                    Text("\(category.name)")
                                        .foregroundColor(.primary)
                                } else {
                                    Text("Выберите")
                                        .foregroundColor(.secondary)
                                }
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 12)
                    Divider()
                    // Сумма
                    HStack {
                        Text("Сумма")
                        Spacer()
                        TextField("0", text: $amount)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .focused($amountFieldFocused)
                            .onChange(of: amount) { oldValue, newValue in
                                let filtered = newValue.filter { "0123456789. ,".contains($0) }
                                if filtered != newValue { amount = filtered }
                            }
                        Text(currencySymbol)
                            
                            
                    }
                    .padding(.vertical, 12)
                    Divider()
                    // Дата
                    HStack {
                        Text("Дата")
                        Spacer()
                        DatePicker("", selection: $transactionDate, displayedComponents: .date)
                            .labelsHidden()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.accentColor.opacity(0.12))
                            )
                            .foregroundColor(.primary)
                    }
                    .padding(.vertical, 12)
                    Divider()
                    // Время
                    HStack {
                        Text("Время")
                        Spacer()
                        DatePicker("", selection: $transactionDate, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.accentColor.opacity(0.12))
                            )
                            .foregroundColor(.primary)
                    }
                    .padding(.vertical, 12)
                    Divider()
                    // Комментарий
                    HStack(alignment: .top) {
                        if comment.isEmpty {
                            Text("")
                                .foregroundColor(.secondary)
                        }
                        TextField("Комментарий", text: $comment, axis: .vertical)
                            .lineLimit(1...3)
                    }
                    .padding(.vertical, 12)
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color(.black).opacity(0.04), radius: 8, x: 0, y: 2)
                .padding(.horizontal, 8)
                .padding(.top, 8)
                .padding(.bottom, 16)
                
                // Date & Time pickers (hidden, but accessible)
                DatePicker("", selection: $transactionDate, displayedComponents: [.date, .hourAndMinute])
                    .labelsHidden()
                    .frame(height: 0)
                    .opacity(0)
                
                Spacer()
                
                // Delete button
                if !isCreateMode {
                    Button(action: deleteTransaction) {
                        Text("Удалить расход")
                            .foregroundColor(.red)
                            .font(.system(size: 17, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                    }
                }
            }
            .sheet(isPresented: $showingCategoryPicker) {
                CategoryPickerView(
                    categories: availableCategories,
                    selectedCategory: $selectedCategory
                )
            }
            .alert("Ошибка", isPresented: .constant(errorMessage != nil)) {
                Button("OK") { errorMessage = nil }
            } message: {
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                }
            }
            .onAppear { setupInitialData() }
        }
    }
    
    private func setupInitialData() {
        Task {
            await loadCategories()
            if let transaction = transaction {
                selectedCategory = transaction.category
                let amountValue = NSDecimalNumber(decimal: transaction.amount).doubleValue
                amount = String(format: "%.0f", amountValue)
                transactionDate = transaction.transactionDate
                comment = transaction.comment
            } else {
                transactionDate = Date()
                comment = ""
                amount = ""
            }
        }
    }
    private func loadCategories() async {
        availableCategories = await categoriesService.categories(for: direction)
    }
    private func saveTransaction() {
        guard let category = selectedCategory else {
            errorMessage = "Пожалуйста, выберите статью"
            return
        }
        guard !amount.isEmpty else {
            errorMessage = "Пожалуйста, введите сумму"
            return
        }
        let cleanAmount = amount.replacingOccurrences(of: ",", with: ".")
            .replacingOccurrences(of: " ", with: "")
        guard let amountDecimal = Decimal(string: cleanAmount) else {
            errorMessage = "Пожалуйста, введите корректную сумму"
            return
        }
        isLoading = true
        Task {
            do {
                if isCreateMode {
                    let account = try await bankAccountsService.getAccount()
                    let newTransaction = Transaction(
                        id: Int.random(in: 1000...9999),
                        account: account,
                        category: category,
                        amount: amountDecimal,
                        transactionDate: transactionDate,
                        comment: comment.isEmpty ? "" : comment,
                        createdAt: Date(),
                        updatedAt: Date()
                    )
                    _ = try await transactionsService.add(newTransaction)
                } else {
                    guard let transaction = transaction else { return }
                    _ = try await transactionsService.update(id: transaction.id, keyPath: \.category, value: category)
                    _ = try await transactionsService.update(id: transaction.id, keyPath: \.amount, value: amountDecimal)
                    _ = try await transactionsService.update(id: transaction.id, keyPath: \.transactionDate, value: transactionDate)
                    _ = try await transactionsService.update(id: transaction.id, keyPath: \.comment, value: comment.isEmpty ? "" : comment)
                }
                await MainActor.run {
                    isLoading = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Ошибка при сохранении: \(error.localizedDescription)"
                }
            }
        }
    }
    private func deleteTransaction() {
        guard let transaction = transaction else { return }
        isLoading = true
        Task {
            let success = await transactionsService.delete(id: transaction.id)
            await MainActor.run {
                isLoading = false
                if success {
                    dismiss()
                } else {
                    errorMessage = "Ошибка при удалении операции"
                }
            }
        }
    }
}

enum EditMode {
    case create
    case edit
}

struct CategoryPickerView: View {
    let categories: [Category]
    @Binding var selectedCategory: Category?
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            List(categories, id: \.self) { category in
                Button(action: {
                    selectedCategory = category
                    dismiss()
                }) {
                    HStack {
                        Text("\(category.emoji) \(category.name)")
                            .foregroundColor(.primary)
                        Spacer()
                        if selectedCategory?.id == category.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Выберите статью")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Отмена") { dismiss() }
                }
            }
        }
    }
}

extension DateService {
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: date)
    }
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    TransactionEditView(
        mode: .create,
        direction: .outcome, transaction: nil,
        transactionsService: TransactionsService(),
        categoriesService: CategoriesService(),
        bankAccountsService: BankAccountsService()
    )
}
