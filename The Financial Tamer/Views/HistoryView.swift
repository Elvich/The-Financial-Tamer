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
    
    var body: some View {
        NavigationStack{
            
        }
    }
}

#Preview {
    HistoryView(direction: .outcome)
}
