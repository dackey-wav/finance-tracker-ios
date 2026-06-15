//
//  AppSection.swift
//  FinanceTracker
//
//  Created by dan on 15/06/2026.
//


import SwiftUI

enum AppSection: String, CaseIterable, Identifiable {
    case transactions = "Transactions"
    case add = "Add"
    case statistics = "Statistics"
    case settings = "Categories"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .transactions: return "list.bullet"
        case .add: return "plus.circle"
        case .statistics: return "chart.pie"
        case .settings: return "tag"
        }
    }

    @ViewBuilder
    var destination: some View {
        switch self {
        case .transactions: TransactionListView()
        case .add: AddTransactionView()
        case .statistics: StatisticsView()
        case .settings: CategorySettingsView()
        }
    }
}
