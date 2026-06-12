//
//  ContentView.swift
//  Expense Flow App
//
//  Created by Khalifa Waziri on 12/06/2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Dashboard", systemImage: "house.fill") }

            ExpensesListView()
                .tabItem { Label("Expenses", systemImage: "list.bullet") }

            ChartsView()
                .tabItem { Label("Insights", systemImage: "chart.pie.fill") }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Expense.self, inMemory: true)
}
