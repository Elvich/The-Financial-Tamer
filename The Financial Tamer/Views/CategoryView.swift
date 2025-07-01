//
//  CategoryView.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 01.07.2025.
//

import SwiftUI

struct CategoryView: View {
    @State private var categories: [Category] = []
    private let service = CategoriesService()
    
    var body: some View {
        NavigationStack {
            List(categories, id: \ .id) { category in
                HStack {
                    Text(String(category.emoji))
                        
                    Text(category.name)
                        
                }
            }
            .padding(.bottom)
            .navigationTitle("Мои статьи")
            .task {
                categories = await service.categories()
            }
        }
    }
}

#Preview {
    CategoryView()
}
