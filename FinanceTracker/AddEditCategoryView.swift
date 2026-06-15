//
//  AddEditCategoryView.swift
//  FinanceTracker
//
//  Created by dan on 15/06/2026.
//


import SwiftUI
import SwiftData

struct AddEditCategoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    private var categoryToEdit: Category?

    @State private var name: String
    @State private var selectedIcon: String
    @State private var selectedColorHex: String

    // set of symbols and colors to avoid dealing with a full color picker / icon search UI.
    private let availableIcons = [
        "fork.knife", "cart", "house", "car", "bus", "airplane",
        "bag", "gift", "heart", "gamecontroller", "book", "creditcard",
        "tv", "phone", "pawprint", "graduationcap"
    ]

    private let availableColors = [
        "FF3B30", "FF9500", "FFCC00", "34C759",
        "00C7BE", "007AFF", "5856D6", "AF52DE", "FF2D55", "8E8E93"
    ]

    init(categoryToEdit: Category? = nil) {
        self.categoryToEdit = categoryToEdit
        _name = State(initialValue: categoryToEdit?.name ?? "")
        _selectedIcon = State(initialValue: categoryToEdit?.icon ?? "tag")
        _selectedColorHex = State(initialValue: categoryToEdit?.colorHex ?? "007AFF")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Category name", text: $name)
                }

                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                        ForEach(availableIcons, id: \.self) { icon in
                            Image(systemName: icon)
                                .font(.title2)
                                .frame(width: 36, height: 36)
                                .background(selectedIcon == icon ? Color(hex: selectedColorHex).opacity(0.2) : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(selectedIcon == icon ? Color(hex: selectedColorHex) : .clear, lineWidth: 2)
                                )
                                .onTapGesture {
                                    selectedIcon = icon
                                }
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(availableColors, id: \.self) { hex in
                            Circle()
                                .fill(Color(hex: hex))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .stroke(.primary, lineWidth: selectedColorHex == hex ? 2 : 0)
                                        .padding(-3)
                                )
                                .onTapGesture {
                                    selectedColorHex = hex
                                }
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Preview") {
                    Label(name.isEmpty ? "Category name" : name, systemImage: selectedIcon)
                        .foregroundStyle(Color(hex: selectedColorHex))
                }
            }
            .navigationTitle(categoryToEdit == nil ? "New Category" : "Edit Category")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }   

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        if let category = categoryToEdit {
            category.name = trimmedName
            category.icon = selectedIcon
            category.colorHex = selectedColorHex
        } else {
            let newCategory = Category(name: trimmedName, colorHex: selectedColorHex, icon: selectedIcon)
            modelContext.insert(newCategory)
        }
        dismiss()
    }
}
