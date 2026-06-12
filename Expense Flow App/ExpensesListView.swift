//
//  ExpensesListView.swift
//  Expense Flow App
//
//  Created by Khalifa Waziri on 12/06/2026.
//

import SwiftUI
import SwiftData

struct ExpensesListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]

    @State private var searchText = ""
    @State private var selectedCategory: ExpenseCategory?
    @State private var expenseToEdit: Expense?
    @State private var showingAddExpense = false

    private var filteredExpenses: [Expense] {
        expenses.filter { expense in
            let matchesSearch = searchText.isEmpty ||
                expense.title.localizedCaseInsensitiveContains(searchText)
            let matchesCategory = selectedCategory == nil || expense.category == selectedCategory
            return matchesSearch && matchesCategory
        }
    }

    private var groupedExpenses: [(key: Date, value: [Expense])] {
        let grouped = Dictionary(grouping: filteredExpenses) { expense in
            Calendar.current.startOfDay(for: expense.date)
        }
        return grouped.sorted { $0.key > $1.key }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                categoryFilterBar

                if filteredExpenses.isEmpty {
                    Spacer()
                    EmptyStateView(
                        icon: "magnifyingglass",
                        title: "No results",
                        message: "Try a different search or filter"
                    )
                    Spacer()
                } else {
                    List {
                        ForEach(groupedExpenses, id: \.key) { group in
                            Section(header: Text(group.key.formatted(date: .abbreviated, time: .omitted))) {
                                ForEach(group.value) { expense in
                                    ExpenseRowView(expense: expense)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            expenseToEdit = expense
                                        }
                                }
                                .onDelete { offsets in
                                    delete(offsets: offsets, from: group.value)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .searchable(text: $searchText, prompt: "Search expenses")
            .navigationTitle("Expenses")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddExpense = true
                    } label: {
                        Image(systemName: "plus.circle")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                AddEditExpenseView()
            }
            .sheet(item: $expenseToEdit) { expense in
                AddEditExpenseView(expense: expense)
            }
        }
    }

    private var categoryFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                CategoryPill(title: "All", icon: "square.grid.2x2", color: .black, isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }
                ForEach(ExpenseCategory.allCases) { category in
                    CategoryPill(
                        title: category.rawValue,
                        icon: category.icon,
                        color: category.color,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = selectedCategory == category ? nil : category
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    private func delete(offsets: IndexSet, from group: [Expense]) {
        for index in offsets {
            modelContext.delete(group[index])
        }
    }
}

#Preview {
    ExpensesListView()
        .modelContainer(for: Expense.self, inMemory: true)
}
