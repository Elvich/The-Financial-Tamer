//
//  CategoryView.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 01.07.2025.
//

import SwiftUI

struct CategoryView: View {
    @State private var categories: [Category] = []
    @State private var searchText: String = ""
    private let service = CategoriesService()
    
    var filteredCategories: [Category] {
        if searchText.isEmpty {
            return categories
        } else {
            return categories.filter { category in
                category.name.localizedCaseInsensitiveContains(searchText) ||
                String(category.emoji).localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List(filteredCategories, id: \ .id) { category in
                HStack {
                    Text(String(category.emoji))
                    Text(category.name)
                }
            }
            .padding(.bottom)
            .navigationTitle("Мои статьи")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Поиск по названию или эмодзи")
            .task {
                categories = await service.categories()
            }
        }
    }
}

#Preview {
    CategoryView()
}
