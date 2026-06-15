//
//  StatisticsView.swift
//  FinanceTracker
//
//  Created by dan on 15/06/2026.
//


import SwiftUI
import SwiftData
import Charts

struct StatisticsView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Query private var transactions: [Transaction]

    private struct CategorySpending: Identifiable {
        let id: PersistentIdentifier?
        let name: String
        let amount: Double
        let colorHex: String
    }

    private struct MonthlySpending: Identifiable {
        let id = UUID()
        let month: Date
        let total: Double
    }

    private var categorySpending: [CategorySpending] {
        let grouped = Dictionary(grouping: transactions) { $0.category?.persistentModelID }
        return grouped.map { (key, items) in
            CategorySpending(
                id: key,
                name: items.first?.category?.name ?? "Uncategorized",
                amount: items.reduce(0) { $0 + $1.amount },
                colorHex: items.first?.category?.colorHex ?? "8E8E93"
            )
        }
        .sorted { $0.amount > $1.amount }
    }

    private var totalSpending: Double {
        transactions.reduce(0) { $0 + $1.amount }
    }

    private var monthlySpending: [MonthlySpending] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: transactions) { transaction in
            calendar.dateInterval(of: .month, for: transaction.date)?.start ?? transaction.date
        }
        return grouped
            .map { MonthlySpending(month: $0.key, total: $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.month < $1.month }
    }

    var body: some View {
        ScrollView {
            if transactions.isEmpty {
                ContentUnavailableView(
                    "No data yet",
                    systemImage: "chart.pie",
                    description: Text("Add some transactions to see statistics.")
                )
                .padding(.top, 60)
            } else if horizontalSizeClass == .regular {
                HStack(alignment: .top, spacing: 16) {
                    categorySection
                    monthlySection
                }
                .padding()
            } else {
                VStack(spacing: 24) {
                    categorySection
                    monthlySection
                }
                .padding()
            }
        }
        .navigationTitle("Statistics")
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("By Category")
                .font(.headline)

            Chart(categorySpending) { item in
                SectorMark(
                    angle: .value("Amount", item.amount),
                    innerRadius: .ratio(0.55),
                    angularInset: 1.5
                )
                .foregroundStyle(Color(hex: item.colorHex))
                .cornerRadius(4)
            }
            .frame(height: 220)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(categorySpending) { item in
                    HStack {
                        Circle()
                            .fill(Color(hex: item.colorHex))
                            .frame(width: 10, height: 10)
                        Text(item.name)
                        Spacer()
                        Text(item.amount, format: .currency(code: "PLN"))
                            .foregroundStyle(.secondary)
                        Text("(\(percentage(of: item.amount))%)")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                }
                Divider()
                HStack {
                    Text("Total")
                        .fontWeight(.semibold)
                    Spacer()
                    Text(totalSpending, format: .currency(code: "PLN"))
                        .fontWeight(.semibold)
                }
            }
        }
        .padding()
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 12))
    }

    private var monthlySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Over Time")
                .font(.headline)

            Chart(monthlySpending) { item in
                BarMark(
                    x: .value("Month", item.month, unit: .month),
                    y: .value("Total", item.total)
                )
                .foregroundStyle(.blue.gradient)
            }
            .frame(height: 220)
            .chartXAxis {
                AxisMarks(values: .stride(by: .month)) { value in
                    AxisValueLabel(format: .dateTime.month(.abbreviated))
                }
            }
        }
        .padding()
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 12))
    }

    private func percentage(of amount: Double) -> String {
        guard totalSpending > 0 else { return "0" }
        return String(format: "%.0f", amount / totalSpending * 100)
    }
}
