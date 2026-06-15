//
//  Category.swift
//  FinanceTracker
//
//  Created by dan on 15/06/2026.
//


import Foundation
import SwiftData

@Model
final class Category {
    var name: String
    var colorHex: String
    var icon: String

    @Relationship(deleteRule: .nullify, inverse: \Transaction.category)
    var transactions: [Transaction] = []

    init(name: String, colorHex: String = "007AFF", icon: String = "tag") {
        self.name = name
        self.colorHex = colorHex
        self.icon = icon
    }
}
