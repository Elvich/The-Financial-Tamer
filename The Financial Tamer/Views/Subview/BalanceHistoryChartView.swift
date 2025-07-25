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
    
    var body: some View {
        VStack {
            if balanceHistoryDatas.isEmpty {
                ProgressView("Загрузка...")
                    .frame(height: 200)
            } else {
                Chart(balanceHistoryDatas) {
                    BarMark(
                        x: .value("Дата", $0.date, unit: .day),
                        y: .value("Баланс", NSDecimalNumber(decimal: $0.count).doubleValue)
                    )
                    .foregroundStyle($0.isPositive ? Color.accentColor : Color.red)
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: 10)) { _ in
                        AxisValueLabel(format: .dateTime.day(), centered: true)
                    }
                }
                .chartYAxis(.hidden)
                .padding()
                .frame(height: 200)
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

extension BalanceHistoryChartView{
    struct BalanceHistoryData: Identifiable{
        let id = UUID()
        
        let date: Date
        let count: Decimal
        let isPositive: Bool
    }
    
    func makeDataPack() async throws -> [BalanceHistoryData]{
        var balanceHistoryDatas: [BalanceHistoryData] = []
        
        for i in 0...30{
            let day = appDependency.dateService.calendar.date(
                byAdding: .day,
                value: -i,
                to: appDependency.dateService.now
            )!
            balanceHistoryDatas.append(try await makeDay(date: appDependency.dateService.endOfDay(date: day)))
        }
        
        return balanceHistoryDatas
    }
    
    private func makeDay(date: Date) async throws -> BalanceHistoryData{
        let start = appDependency.dateService.startOfDay(date: date)
        let end = appDependency.dateService.endOfDay(date: date)
        let transactionsIn = try await appDependency.transactionsService.getTransactions(start: start, end: end, direction: .income, hardRefresh: true).reduce(Decimal.zero) { $0 + $1.amount }
        let transactionsOut = try await appDependency.transactionsService.getTransactions(start: start, end: end, direction: .outcome, hardRefresh: true).reduce(Decimal.zero) { $0 + $1.amount }
        
        if transactionsIn>=transactionsOut{
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
