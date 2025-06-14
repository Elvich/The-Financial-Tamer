//
//  TransactionsListView.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 14.06.2025.
//

import SwiftUI

struct TransactionsListView: View {
    
    let direction: Direction
    
    var body: some View {
        NavigationStack{
            Text("Привет, это страница \(direction)!")
        }.navigationTitle("\(direction == .outcome ? "Расходы" : "Доходы") сегодня")
    }
}

#Preview {
    TransactionsListView(direction: .outcome)
}
