//
//  TransactionsListView.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 14.06.2025.
//

import SwiftUI

struct TransactionsListView: View {
    
    let direction: Direction
    var transactionService = TransactionsService()
    

    var body: some View {
        
        
        NavigationStack {
            LazyVStack {
                Text("Привет, это страница \(direction)!")
                
                ForEach(transactionService.getTransactions(), id: \.id) { transaction in
                    NavigationLink(value: transaction) {
                        HStack{
                            Text("Транзакция $\(transaction.amount)")
                        }
                    }
                }
                
                Spacer()
                
                ScrollView {
                    VStack{
                        
                        }
                    }
                }
            }
            .navigationTitle(direction == .outcome ? "Расходы" : "Доходы" + " сегодня")
        }
    }

    
#Preview {
    TransactionsListView(direction: .income)
}
