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
    @State private var validationErrors: Set<ValidationField> = []
    @FocusState private var amountFieldFocused: Bool
    
    private var isCreateMode: Bool { mode == .create }
    private var title: String {
        if direction == .outcome { return "Мои Расходы" }
        else { return "Мои Доходы" }
    }
    private var saveButtonTitle: String { isCreateMode ? "Создать" : "Сохранить" }
    private var canSave: Bool { !amount.isEmpty && selectedCategory != nil }
    private var currencySymbol: String { currencyService.getSymbol(for: "RUB") }
    
    // Получаем разделитель в зависимости от локали пользователя
    private var decimalSeparator: String {
        Locale.current.decimalSeparator ?? "."
    }
    
    // Максимальная дата для выбора (сегодня)
    private var maxDate: Date {
        Calendar.current.startOfDay(for: Date())
    }
    
    // Enum для полей валидации
    enum ValidationField: CaseIterable {
        case category
        case amount
    }
    
    // Проверка валидности всех полей
    private func validateFields() -> Bool {
        validationErrors.removeAll()
        
        // Проверка категории
        if selectedCategory == nil {
            validationErrors.insert(.category)
        }
        
        // Проверка суммы
        if amount.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationErrors.insert(.amount)
        } else {
            let cleanAmount = amount.replacingOccurrences(of: decimalSeparator, with: ".")
            if Decimal(string: cleanAmount) == nil {
                validationErrors.insert(.amount)
            }
        }
        
        return validationErrors.isEmpty
    }
    
    // Получение сообщения об ошибке валидации
    private func getValidationErrorMessage() -> String {
        var missingFields: [String] = []
        
        if validationErrors.contains(.category) {
            missingFields.append("статья")
        }
        if validationErrors.contains(.amount) {
            missingFields.append("сумма")
        }
        
        if missingFields.count == 1 {
            return "Пожалуйста, заполните поле: \(missingFields[0])"
        } else if missingFields.count > 1 {
            let fieldsString = missingFields.dropLast().joined(separator: ", ") + " и " + missingFields.last!
            return "Пожалуйста, заполните поля: \(fieldsString)"
        }
        
        return "Пожалуйста, заполните все обязательные поля"
    }
    
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
                        .disabled(isLoading)
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
                            .foregroundColor(validationErrors.contains(.category) ? .red : .primary)
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
                                        .foregroundColor(validationErrors.contains(.category) ? .red : .secondary)
                                }
                                Image(systemName: "chevron.right")
                                    .foregroundColor(validationErrors.contains(.category) ? .red : .secondary)
                                    .font(.caption)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(validationErrors.contains(.category) ? Color.red.opacity(0.1) : Color.clear)
                    )
                    Divider()
                    // Сумма
                    HStack {
                        Text("Сумма")
                            .foregroundColor(validationErrors.contains(.amount) ? .red : .primary)
                        Spacer()
                        TextField("0", text: $amount)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .focused($amountFieldFocused)
                            .foregroundColor(validationErrors.contains(.amount) ? .red : .primary)
                            .onChange(of: amount) { oldValue, newValue in
                                // Очищаем ошибку валидации при изменении
                                validationErrors.remove(.amount)
                                
                                // Разрешаем только цифры и один разделитель в зависимости от локали
                                let allowedChars = "0123456789" + decimalSeparator
                                let filtered = newValue.filter { allowedChars.contains($0) }
                                
                                // Проверяем, что разделитель используется только один раз
                                let separatorCount = filtered.filter { String($0) == decimalSeparator }.count
                                if separatorCount > 1 {
                                    // Удаляем все разделители кроме первого
                                    let components = filtered.components(separatedBy: decimalSeparator)
                                    if components.count > 1 {
                                        let firstComponent = components[0]
                                        let remainingComponents = components.dropFirst().joined()
                                        amount = firstComponent + decimalSeparator + remainingComponents
                                    }
                                } else if filtered != newValue {
                                    amount = filtered
                                }
                            }
                        Text(currencySymbol)
                            .foregroundColor(validationErrors.contains(.amount) ? .red : .primary)
                    }
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(validationErrors.contains(.amount) ? Color.red.opacity(0.1) : Color.clear)
                    )
                    Divider()
                    // Дата
                    HStack {
                        Text("Дата")
                        Spacer()
                        DatePicker("", selection: $transactionDate, in: ...maxDate, displayedComponents: .date)
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
                DatePicker("", selection: $transactionDate, in: ...maxDate, displayedComponents: [.date, .hourAndMinute])
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
                    selectedCategory: $selectedCategory,
                    onCategorySelected: {
                        validationErrors.remove(.category)
                    }
                )
            }
            .alert("Внимание", isPresented: .constant(errorMessage != nil)) {
                Button("OK") { 
                    errorMessage = nil
                    validationErrors.removeAll()
                }
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
                // Форматируем сумму с учетом локали пользователя
                let formatter = NumberFormatter()
                formatter.locale = Locale.current
                formatter.minimumFractionDigits = 0
                formatter.maximumFractionDigits = 2
                amount = formatter.string(from: NSNumber(value: amountValue)) ?? String(format: "%.0f", amountValue)
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
        // Проверяем валидность всех полей
        if !validateFields() {
            errorMessage = getValidationErrorMessage()
            return
        }
        
        guard let category = selectedCategory else {
            errorMessage = "Пожалуйста, выберите статью"
            return
        }
        
        // Преобразуем разделитель в стандартный формат для Decimal
        let cleanAmount = amount.replacingOccurrences(of: decimalSeparator, with: ".")
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
    var onCategorySelected: (() -> Void)?
    
    var body: some View {
        NavigationStack {
            List(categories, id: \.self) { category in
                Button(action: {
                    selectedCategory = category
                    onCategorySelected?()
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
        bankAccountsService: BankAccountsService(networkClient: DefaultNetworkClient())
    )
}
