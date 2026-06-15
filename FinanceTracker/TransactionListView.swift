//
//  TransactionListView.swift
//  FinanceTracker
//
//  Created by dan on 15/06/2026.
//


import SwiftUI
import SwiftData

struct TransactionListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    @Query private var categories: [Category]

    private var groupedTransactions: [(date: Date, items: [Transaction])] {
        let grouped = Dictionary(grouping: transactions) { transaction in
            Calendar.current.startOfDay(for: transaction.date)
        }
        return grouped
            .map { (date: $0.key, items: $0.value) }
            .sorted { $0.date > $1.date }
    }

    var body: some View {
        List {
            ForEach(groupedTransactions, id: \.date) { group in
                Section {
                    ForEach(group.items) { transaction in
                        NavigationLink {
                            TransactionDetailView(transaction: transaction)
                        } label: {
                            TransactionRow(transaction: transaction)
                        }
                    }
                    .onDelete { offsets in
                        delete(items: group.items, at: offsets)
                    }
                } header: {
                    Text(group.date, format: .dateTime.day().month().year())
                }
            }
        }
        .overlay {
            if transactions.isEmpty {
                ContentUnavailableView(
                    "No transactions yet",
                    systemImage: "list.bullet",
                    description: Text("Use the 'Add' tab to create your first transaction.")
                )
            }
        }
    }

    private func delete(items: [Transaction], at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(items[index])
        }
    }
}

private struct TransactionRow: View {
    let transaction: Transaction

    var body: some View {
        HStack {
            Image(systemName: transaction.category?.icon ?? "questionmark.circle")
                .foregroundStyle(Color(hex: transaction.category?.colorHex ?? "8E8E93"))
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.category?.name ?? "Uncategorized")
                if !transaction.note.isEmpty {
                    Text(transaction.note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            Text(transaction.amount, format: .currency(code: "PLN"))
                .fontWeight(.medium)
        }
    }
}
