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
    
    @State private var balanceHistoryDatas: [BalanceHistoryData] = []
    @State private var selectedValue: String = ""
    
    var body: some View {
        VStack {
            if balanceHistoryDatas.isEmpty {
                ProgressView("Загрузка...")
                    .frame(height: 200)
            } else {
                Chart(balanceHistoryDatas) { data in
                    BarMark(
                        x: .value("Дата", data.date, unit: .day),
                        y: .value("Баланс", NSDecimalNumber(decimal: data.count).doubleValue)
                    )
                    .foregroundStyle(data.isPositive ? Color.accentColor : Color.red)
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: 10)) { _ in
                        AxisValueLabel(format: .dateTime.day(), centered: true)
                    }
                }
                .chartYAxis(.hidden)
                .padding()
                .frame(height: 200)
                .chartOverlay { proxy in
                    GeometryReader { geometry in
                        Rectangle()
                            .fill(Color.clear)
                            .contentShape(Rectangle())
                            .onTapGesture { location in
                                let frame = geometry[proxy.plotAreaFrame]
                                
                                // Проверяем, попал ли клик в область графика
                                guard frame.contains(location) else { return }
                                
                                // Преобразуем позицию клика в значение по оси X
                                let relativeX = location.x - frame.origin.x
                                let chartWidth = frame.width
                                
                                // Вычисляем индекс на основе позиции
                                let index = Int((relativeX / chartWidth) * CGFloat(balanceHistoryDatas.count))
                                
                                
                                if index >= 0 && index < balanceHistoryDatas.count {
                                    selectedValue = String(format: "%.2f", NSDecimalNumber(decimal: balanceHistoryDatas[index].count).doubleValue)
                                }
                            }
                    
                    }
                }
            }
            
            // Отображаем последнее выбранное значение
            if !selectedValue.isEmpty {
                Text("\(selectedValue)")
                    .font(.headline)
                    .padding()
            }
        }
        .task {
            do {
                balanceHistoryDatas = try await makeDataPack()
                balanceHistoryDatas.sort { $0.date < $1.date }
            } catch {
                print("Ошибка загрузки данных: $error)")
            }
        }
    }
}


extension BalanceHistoryChartView {
    struct BalanceHistoryData: Identifiable {
        let id = UUID()
        
        let date: Date
        let count: Decimal
        let isPositive: Bool
    }
    
    func makeDataPack() async throws -> [BalanceHistoryData] {
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
    
    private func makeDay(date: Date) async throws -> BalanceHistoryData {
        let start = appDependency.dateService.startOfDay(date: date)
        let end = appDependency.dateService.endOfDay(date: date)
        let transactionsIn = try await appDependency.transactionsService.getTransactions(start: start, end: end, direction: .income, hardRefresh: true).reduce(Decimal.zero) { $0 + $1.amount }
        let transactionsOut = try await appDependency.transactionsService.getTransactions(start: start, end: end, direction: .outcome, hardRefresh: true).reduce(Decimal.zero) { $0 + $1.amount }
        
        if transactionsIn >= transactionsOut {
            let count: Decimal = transactionsIn - transactionsOut
            return BalanceHistoryData(date: date, count: count, isPositive: true)
        }
        
        return BalanceHistoryData(date: date, count: transactionsOut - transactionsIn, isPositive: false)
    }
}

#Preview {
    BalanceHistoryChartView()
        .environmentObject(AppDependency())
}
