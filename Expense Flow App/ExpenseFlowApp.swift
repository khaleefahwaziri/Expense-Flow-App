//
//  Expense_Flow_AppApp.swift
//  Expense Flow App
//
//  Created by Khalifa Waziri on 12/06/2026.
//

import SwiftUI
import SwiftData

@main
struct ExpenseFlowApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Expense.self)
    }
}
