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
            VStack{
                
                HStack{
                    Text("Всего")
                    
                    Spacer()
                    
                    Text("Очень много $")
                }
                .padding(.horizontal)
                
                
                
                List(transactionService.getTransactions(direction), id: \.self){ transition in
                    HStack{
                        Text("\(transition.category.emoji)    \(transition.category.name)")
                        
                        Spacer()
                        
                        Text("\(transition.amount) $")
                        Text(">")
                    }
                    
                }
            }
            .background(Color(uiColor: UIColor.systemGroupedBackground))
            
            .navigationTitle((direction == .outcome ? "Расходы" : "Доходы") + " сегодня")
            
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink(destination: ErrorView()) {
                        Image(systemName: "clock")
                            .foregroundColor(.purple)
                    }
                }
            }
            
        }
    }
}

    
#Preview {
    TransactionsListView(direction: .income)
}
