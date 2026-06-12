//
//  Models.swift
//  Expense Flow App
//
//  Created by Khalifa Waziri on 12/06/2026.
//
import Foundation
import SwiftUI
import SwiftData

@Model
final class Expense {
    var title: String
    var amount: Double
    var categoryRaw: String
    var date: Date
    var note: String

    init(title: String, amount: Double, category: ExpenseCategory, date: Date = .now, note: String = "") {
        self.title = title
        self.amount = amount
        self.categoryRaw = category.rawValue
        self.date = date
        self.note = note
    }

    var category: ExpenseCategory {
        get { ExpenseCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }
}

enum ExpenseCategory: String, CaseIterable, Identifiable, Codable {
    case food = "Food"
    case transport = "Transport"
    case shopping = "Shopping"
    case entertainment = "Entertainment"
    case bills = "Bills"
    case health = "Health"
    case groceries = "Groceries"
    case other = "Other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .transport: return "car.fill"
        case .shopping: return "bag.fill"
        case .entertainment: return "film.fill"
        case .bills: return "doc.text.fill"
        case .health: return "heart.fill"
        case .groceries: return "cart.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .food: return .orange
        case .transport: return .blue
        case .shopping: return .pink
        case .entertainment: return .purple
        case .bills: return .red
        case .health: return .green
        case .groceries: return .mint
        case .other: return .gray
        }
    }
}
