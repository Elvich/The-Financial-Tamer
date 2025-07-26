//
//  BalanceHistoryChartView.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 26.07.2025.
//

import SwiftUI
import Charts

struct BalanceHistoryChartView: View {
    
    @EnvironmentObject var appDependency: AppDependency
    
    enum ChartPeriod: String, CaseIterable {
        case daily = "Дни"
        case monthly = "Месяцы"
    }
    
    @State private var balanceHistoryDatas: [BalanceHistoryData] = []
    @State private var selectedValue: String = ""
    @State private var selectedPeriod: ChartPeriod = .daily
    @State private var isLoading = false
    
    var body: some View {
        VStack {
            // Segmented Control
            Picker("Период", selection: $selectedPeriod) {
                ForEach(ChartPeriod.allCases, id: \.self) { period in
                    Text(period.rawValue).tag(period)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            if isLoading {
                ProgressView("Загрузка...")
                    .frame(height: 200)
            } else if balanceHistoryDatas.isEmpty {
                VStack {
                    Image(systemName: "chart.bar.fill")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("Нет данных")
                        .foregroundColor(.secondary)
                }
                .frame(height: 200)
            } else {
                Chart(balanceHistoryDatas) { data in
                    BarMark(
                        x: .value("Дата", data.date),
                        y: .value("Баланс", Double(truncating: NSDecimalNumber(decimal: data.count)))
                    )
                    .foregroundStyle(data.isPositive ? Color.accentColor : Color.red)
                }
                .chartXAxis {
                    AxisMarks { value in
                        if let date = value.as(Date.self) {
                            AxisGridLine()
                            AxisValueLabel {
                                Text(selectedPeriod == .daily
                                     ? dateFormatter.string(from: date)
                                     : monthYearFormatter.string(from: date))
                            }
                        }
                    }
                }
                .chartYAxis(.hidden)
                .padding()
                .frame(height: 200)
                .animation(.easeInOut, value: balanceHistoryDatas)
                .chartOverlay { proxy in
                    GeometryReader { geometry in
                        Rectangle()
                            .fill(Color.clear)
                            .contentShape(Rectangle())
                            .onTapGesture { location in
                                handleChartTap(location: location, proxy: proxy, geometry: geometry)
                            }
                    }
                }
            }
            
            // Отображаем последнее выбранное значение
            if !selectedValue.isEmpty {
                Text("Баланс: \(selectedValue)")
                    .font(.headline)
                    .padding()
                    .transition(.opacity)
            }
        }
        .task {
            await loadData()
        }
        .onChange(of: selectedPeriod) { _ in
            Task {
                await loadData()
            }
        }
    }
    
    private func handleChartTap(location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) {
        let frame = geometry[proxy.plotAreaFrame]
        
        // Проверяем, попал ли клик в область графика
        guard frame.contains(location) else { return }
        
        // Преобразуем позицию клика в значение по оси X
        let dateFromX = proxy.value(atX: location.x) as Date?
        
        if let closestData = balanceHistoryDatas.min(by: {
            abs($0.date.timeIntervalSince(dateFromX ?? Date())) <
            abs($1.date.timeIntervalSince(dateFromX ?? Date()))
        }) {
            withAnimation {
                selectedValue = String(format: "%.2f", Double(truncating: NSDecimalNumber(decimal: closestData.count)))
            }
        }
    }
    
    private func loadData() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            switch selectedPeriod {
            case .daily:
                balanceHistoryDatas = try await makeDailyDataPack()
            case .monthly:
                balanceHistoryDatas = try await makeMonthlyDataPack()
            }
            balanceHistoryDatas.sort { $0.date < $1.date }
        } catch {
            print("Ошибка загрузки данных: \(error)")
            balanceHistoryDatas = []
        }
    }
}

// MARK: - Data Models and Helpers
extension BalanceHistoryChartView {
    struct BalanceHistoryData: Identifiable, Equatable {
        let id = UUID()
        
        let date: Date
        let count: Decimal
        let isPositive: Bool
    }
    
    private func makeDailyDataPack() async throws -> [BalanceHistoryData] {
        var balanceHistoryDatas: [BalanceHistoryData] = []
        
        for i in 0...30 {
            let day = appDependency.dateService.calendar.date(
                byAdding: .day,
                value: -i,
                to: appDependency.dateService.now
            )!
            balanceHistoryDatas.append(try await makeDay(date: appDependency.dateService.endOfDay(date: day)))
        }
        
        return balanceHistoryDatas
    }
    
    private func makeMonthlyDataPack() async throws -> [BalanceHistoryData] {
        var monthlyDatas: [BalanceHistoryData] = []
        
        for i in 0..<24 {
            let monthEndDate = appDependency.dateService.calendar.date(
                byAdding: .month,
                value: -i,
                to: appDependency.dateService.now
            )!
            
            let monthlyData = try await makeMonth(start: monthEndDate, end: monthEndDate)
            monthlyDatas.append(monthlyData)
        }
        
        return monthlyDatas
    }
    
    private func makeDay(date: Date) async throws -> BalanceHistoryData {
        let start = appDependency.dateService.startOfDay(date: date)
        let end = appDependency.dateService.endOfDay(date: date)
        let transactionsIn = try await appDependency.transactionsService.getTransactions(start: start, end: end, direction: .income, hardRefresh: true).reduce(Decimal.zero) { $0 + $1.amount }
        let transactionsOut = try await appDependency.transactionsService.getTransactions(start: start, end: end, direction: .outcome, hardRefresh: true).reduce(Decimal.zero) { $0 + $1.amount }
        
        let balance = transactionsIn - transactionsOut
        return BalanceHistoryData(date: date, count: abs(balance), isPositive: balance >= 0)
    }
    
    private func makeMonth(start: Date, end: Date) async throws -> BalanceHistoryData {
        let transactionsIn = try await appDependency.transactionsService.getTransactions(start: start, end: end, direction: .income, hardRefresh: true).reduce(Decimal.zero) { $0 + $1.amount }
        let transactionsOut = try await appDependency.transactionsService.getTransactions(start: start, end: end, direction: .outcome, hardRefresh: true).reduce(Decimal.zero) { $0 + $1.amount }
        
        let balance = transactionsIn - transactionsOut
        // Используем конец месяца для отображения на графике
        return BalanceHistoryData(date: end, count: abs(balance), isPositive: balance >= 0)
    }
}

// MARK: - Formatters
extension BalanceHistoryChartView {
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter
    }
    
    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter
    }
}

#Preview {
    BalanceHistoryChartView()
        .environmentObject(AppDependency())
}
