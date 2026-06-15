//
//  TransactionDetailView.swift
//  FinanceTracker
//
//  Created by dan on 15/06/2026.
//


import SwiftUI
import SwiftData

struct TransactionDetailView: View {
    @Bindable var transaction: Transaction
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Category.name) private var categories: [Category]

    @State private var showingDeleteConfirmation = false

    var body: some View {
        Form {
            Section("Amount") {
                TextField("Amount", value: $transaction.amount, format: .number.precision(.fractionLength(2)))
                    .keyboardType(.decimalPad)
            }

            Section("Category") {
                Picker("Category", selection: $transaction.category) {
                    Text("None").tag(nil as Category?)
                    ForEach(categories) { category in
                        Label(category.name, systemImage: category.icon)
                            .tag(category as Category?)
                    }
                }
                .pickerStyle(.menu)
            }

            Section("Date") {
                DatePicker("Date", selection: $transaction.date, displayedComponents: [.date, .hourAndMinute])
            }

            Section("Note") {
                TextField("Optional note", text: $transaction.note)
            }

            Section {
                Button("Delete Transaction", role: .destructive) {
                    showingDeleteConfirmation = true
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .navigationTitle("Transaction")
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
        .alert("Delete this transaction?", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                modelContext.delete(transaction)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }
}
