//
//  ChartsView.swift
//  Expense Flow App
//
//  Created by Khalifa Waziri on 12/06/2026.
//

import SwiftUI
import SwiftData
import Charts

struct ChartsView: View {
    @Query private var expenses: [Expense]
    @State private var selectedRange: TimeRange = .week

    enum TimeRange: String, CaseIterable, Identifiable {
        case week = "7 Days"
        case month = "30 Days"
        case sixMonths = "6 Months"

        var id: String { rawValue }
    }

    private var filteredExpenses: [Expense] {
        let calendar = Calendar.current
        let now = Date()
        let cutoff: Date
        switch selectedRange {
        case .week:
            cutoff = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case .month:
            cutoff = calendar.date(byAdding: .day, value: -30, to: now) ?? now
        case .sixMonths:
            cutoff = calendar.date(byAdding: .month, value: -6, to: now) ?? now
        }
        return expenses.filter { $0.date >= cutoff }
    }

    private var dailyTotals: [(date: Date, total: Double)] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredExpenses) { expense in
            calendar.startOfDay(for: expense.date)
        }
        return grouped.map { (date: $0.key, total: $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.date < $1.date }
    }

    private var categoryTotals: [(category: ExpenseCategory, total: Double)] {
        let grouped = Dictionary(grouping: filteredExpenses, by: { $0.category })
        return grouped.map { (category: $0.key, total: $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.total > $1.total }
    }

    private var total: Double {
        filteredExpenses.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Picker("Range", selection: $selectedRange) {
                        ForEach(TimeRange.allCases) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)

                    if filteredExpenses.isEmpty {
                        EmptyStateView(
                            icon: "chart.bar",
                            title: "No data yet",
                            message: "Add some expenses to see insights"
                        )
                        .padding(.top, 60)
                    } else {
                        trendCard
                        categoryRankingCard
                    }
                }
                .padding()
            }
            .navigationTitle("Insights")
            .background(Color(.systemGroupedBackground))
        }
    }

    private var trendCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Spending Trend")
                .font(.headline)

            Text(total, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                .font(.title2.bold())

            Chart(dailyTotals, id: \.date) { item in
                BarMark(
                    x: .value("Date", item.date, unit: .day),
                    y: .value("Total", item.total)
                )
                .foregroundStyle(Color.blue.gradient)
                .cornerRadius(4)
            }
            .frame(height: 200)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var categoryRankingCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top Categories")
                .font(.headline)

            ForEach(categoryTotals, id: \.category) { item in
                VStack(spacing: 6) {
                    HStack {
                        Label(item.category.rawValue, systemImage: item.category.icon)
                            .font(.subheadline)
                        Spacer()
                        Text(item.total, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                            .font(.subheadline.weight(.semibold))
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(.systemGray5))
                                .frame(height: 6)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(item.category.color)
                                .frame(width: geo.size.width * (total > 0 ? item.total / total : 0), height: 6)
                        }
                    }
                    .frame(height: 6)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    ChartsView()
        .modelContainer(for: Expense.self, inMemory: true)
}
