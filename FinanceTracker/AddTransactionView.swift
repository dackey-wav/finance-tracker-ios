//
//  AddTransactionView.swift
//  FinanceTracker
//
//  Created by dan on 15/06/2026.
//


import SwiftUI
import SwiftData

struct AddTransactionView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Category.name) private var categories: [Category]

    @State private var amountText: String = ""
    @State private var selectedCategory: Category?
    @State private var date: Date = .now
    @State private var note: String = ""
    @State private var showValidationError = false

    var body: some View {
        Form {
            Section("Amount") {
                TextField("0.00", text: $amountText)
                    .keyboardType(.decimalPad)
            }

            Section("Category") {
                if categories.isEmpty {
                    Text("No categories yet. Add one in the Categories tab.")
                        .foregroundStyle(.secondary)
                } else {
                    Picker("Category", selection: $selectedCategory) {
                        Text("None").tag(nil as Category?)
                        ForEach(categories) { category in
                            Label(category.name, systemImage: category.icon)
                                .tag(category as Category?)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }

            Section("Date") {
                DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
            }

            Section("Note") {
                TextField("Optional note", text: $note)
            }

            Section {
                Button("Save Transaction") {
                    save()
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .disabled(parsedAmount == nil)
            }

            if showValidationError {
                Text("Please enter a valid amount greater than 0.")
                    .foregroundStyle(.red)
                    .font(.caption)
            }
        }
        .navigationTitle("Add Transaction")
        .scrollDismissesKeyboard(.interactively)
    }

    private var parsedAmount: Double? {
        let normalized = amountText.replacingOccurrences(of: ",", with: ".")
        guard let value = Double(normalized), value > 0 else { return nil }
        return value
    }

    private func save() {
        guard let amount = parsedAmount else {
            showValidationError = true
            return
        }
        showValidationError = false

        let transaction = Transaction(
            amount: amount,
            date: date,
            note: note,
            category: selectedCategory
        )
        modelContext.insert(transaction)

        // reset form
        amountText = ""
        note = ""
        date = .now
    }
}
