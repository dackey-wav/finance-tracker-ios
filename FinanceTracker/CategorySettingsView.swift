//
//  CategorySettingsView.swift
//  FinanceTracker
//
//  Created by dan on 15/06/2026.
//


import SwiftUI
import SwiftData

struct CategorySettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Category.name) private var categories: [Category]

    @State private var showingAddSheet = false
    @State private var categoryToEdit: Category?

    var body: some View {
        List {
            ForEach(categories) { category in
                Button {
                    categoryToEdit = category
                } label: {
                    HStack {
                        Image(systemName: category.icon)
                            .foregroundStyle(Color(hex: category.colorHex))
                            .frame(width: 28)
                        Text(category.name)
                            .foregroundStyle(.primary)
                        Spacer()
                        Text("\(category.transactions.count)")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                }
            }
            .onDelete(perform: deleteCategories)
        }
        .overlay {
            if categories.isEmpty {
                ContentUnavailableView(
                    "No categories",
                    systemImage: "tag",
                    description: Text("Tap + to add your first category.")
                )
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            #if DEBUG
            ToolbarItem(placement: .topBarLeading) {
                Button("Seed Data") {
                    seedSampleData()
                }
            }
            #endif
        }
        .sheet(isPresented: $showingAddSheet) {
            AddEditCategoryView()
        }
        .sheet(item: $categoryToEdit) { category in
            AddEditCategoryView(categoryToEdit: category)
        }
    }

    private func deleteCategories(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(categories[index])
        }
    }
    
    #if DEBUG
    private func seedSampleData() {
        let sampleCategories: [(String, String, String)] = [
            ("Groceries", "FF9500", "cart"),
            ("Transport", "007AFF", "car"),
            ("Entertainment", "AF52DE", "gamecontroller"),
            ("Bills", "FF3B30", "house"),
            ("Health", "34C759", "heart")
        ]

        var createdCategories: [Category] = []
        for (name, color, icon) in sampleCategories {
            if let existing = categories.first(where: { $0.name == name }) {
                createdCategories.append(existing)
            } else {
                let category = Category(name: name, colorHex: color, icon: icon)
                modelContext.insert(category)
                createdCategories.append(category)
            }
        }

        let notes = ["Lunch", "Weekly shopping", "Ticket", "Subscription", "Pharmacy", "Taxi", "Coffee", ""]

        for _ in 0..<60 {
            let daysAgo = Double.random(in: 0...120)
            let date = Calendar.current.date(byAdding: .day, value: -Int(daysAgo), to: .now) ?? .now
            let transaction = Transaction(
                amount: Double.random(in: 5...300).rounded(toPlaces: 2),
                date: date,
                note: notes.randomElement() ?? "",
                category: createdCategories.randomElement()
            )
            modelContext.insert(transaction)
        }
    }
    #endif
}
