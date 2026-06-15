//
//  ContentView.swift
//  FinanceTracker
//
//  Created by dan on 15/06/2026.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var selection: AppSection? = .transactions

    var body: some View {
        if horizontalSizeClass == .regular {
            NavigationSplitView {
                List(AppSection.allCases, selection: $selection) { section in
                    Label(section.rawValue, systemImage: section.icon)
                        .tag(section)
                }
                .navigationTitle("Expenses")
            } detail: {
                if let selection {
                    NavigationStack {
                        selection.destination
                            .navigationTitle(selection.rawValue)
                    }
                } else {
                    Text("Select screen")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }
        } else {
            TabView(selection: $selection) {
                ForEach(AppSection.allCases) { section in
                    NavigationStack {
                        section.destination
                            .navigationTitle(section.rawValue)
                    }
                    .tabItem {
                        Label(section.rawValue, systemImage: section.icon)
                    }
                    .tag(section)
                }
            }
        }
    }
}
