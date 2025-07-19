//
//  CategoryView.swift
//  The Financial Tamer
//
//  Created by Maksim Gritsuk on 01.07.2025.
//

import SwiftUI

struct CategoryView: View {
    let categoriesService: CategoriesService
    @State private var categories: [Category] = []
    @State private var searchText: String = ""
    @State private var isLoading: Bool = false
    
    func fuzzyMatch(_ pattern: String, in text: String) -> Bool {
        if pattern.isEmpty { return true }
        var patternIdx = pattern.startIndex
        let lowerText = text.lowercased()
        let lowerPattern = pattern.lowercased()
        for char in lowerText {
            if char == lowerPattern[patternIdx] {
                patternIdx = lowerPattern.index(after: patternIdx)
                if patternIdx == lowerPattern.endIndex {
                    return true
                }
            }
        }
        return false
    }
    
    var filteredCategories: [Category] {
        if searchText.isEmpty {
            return categories
        } else {
            return categories.filter { category in
                fuzzyMatch(searchText, in: category.name) ||
                String(category.emoji).localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Статьи")) {
                    ForEach(filteredCategories, id: \ .id) { category in
                        HStack {
                            Text(String(category.emoji))
                            Text(category.name)
                        }
                    }
                }
                .refreshable {
                    categories = try! await categoriesService.categories(hardRefresh: true)
                }
            }
            .padding(.bottom)
            .navigationTitle("Мои статьи")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Поиск")
            .task {
                isLoading = true
                categories = try! await categoriesService.categories()
                isLoading = false
            }
        }
    }
}

#Preview {
    CategoryView(categoriesService: CategoriesService(networkClient: DefaultNetworkClient()))
}
