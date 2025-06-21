//
//  HistoryView.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 20.06.2025.
//

import SwiftUI

struct HistoryView: View {
    
    let direction: Direction
    var transactionService = TransactionsService()
    
    @State private var sortType: SortType = .date
    
    @State private var startDate = Date()
    @State private var endDate = Date()
    
    let dateService = DateService.shared
    let transactionsView: TransactionsView

    init(direction: Direction) {
        self.direction = direction
        transactionsView = TransactionsView(direction: direction)

                
        let monthAgo = dateService.calendar.date(byAdding: .month, value: -1, to: dateService.now)!
            
        _startDate = State(initialValue: dateService.startOfDay(date: monthAgo))
        _endDate = State(initialValue: dateService.endOfDay())
    }
    
    var body: some View {
        NavigationStack{
            VStack{
                List{
                    transactionsSettingsSection()
                    transactionsView.transactionsSection(startDate: startDate, endDate: endDate, sortType: sortType)
                }
                .padding(.bottom)
            }
        }
        .navigationTitle("Моя история")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink(destination: ErrorView()) {
                    Image(systemName: "document")
                        .foregroundColor(.purple)
                }
            }
        }
    }
    
    @ViewBuilder
    private func transactionsSettingsSection() -> some View {
              
        HStack() {
            Text("Начало")
            Spacer()
            
            DatePicker("", selection: $startDate, displayedComponents: .date)
                .labelsHidden()
                .background(RoundedRectangle(cornerRadius: 8)
                .fill(Color.accentColor.opacity(0.12)))
                .foregroundColor(.primary)
                .onChange(of: startDate) { _, newDate in
                    endDate = newDate > endDate ? newDate : endDate
                }
        }
        
        HStack() {
            Text("Конеч")
            Spacer()
            DatePicker("", selection: $endDate, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .background(RoundedRectangle(cornerRadius: 8)
                .fill(Color.accentColor.opacity(0.12)))
                .foregroundColor(.primary)
                .onChange(of: endDate) { _, newDate in
                   startDate = newDate < startDate ? newDate : startDate
                }
        }
        
        HStack{
            
            Picker("Сортировать по", selection: $sortType) {
                ForEach(SortType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
        }
        
        transactionsView.totalRowView(text: "Сумма")
        
    }

}

extension HistoryView{
    enum SortType: String, CaseIterable {
        case date = "дате"
        case amount = "сумме"
    }
}

#Preview {
    HistoryView(direction: .outcome)
}
