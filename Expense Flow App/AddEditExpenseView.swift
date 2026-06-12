//
//  AddEditExpenseView.swift
//  Expense Flow App
//
//  Created by Khalifa Waziri on 12/06/2026.
//

import SwiftUI
import SwiftData

struct AddEditExpenseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var expense: Expense?

    @State private var title: String = ""
    @State private var amountText: String = ""
    @State private var category: ExpenseCategory = .other
    @State private var date: Date = .now
    @State private var note: String = ""

    private var isEditing: Bool { expense != nil }

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        Double(amountText) != nil &&
        (Double(amountText) ?? 0) > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Title", text: $title)

                    HStack {
                        Text(Locale.current.currencySymbol ?? "$")
                            .foregroundStyle(.secondary)
                        TextField("Amount", text: $amountText)
                            .keyboardType(.decimalPad)
                    }

                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }

                Section("Category") {
                    Picker("Category", selection: $category) {
                        ForEach(ExpenseCategory.allCases) { category in
                            Label(category.rawValue, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }

                Section("Note (optional)") {
                    TextField("Add a note", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                }

                if isEditing {
                    Section {
                        Button("Delete Expense", role: .destructive) {
                            deleteExpense()
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Expense" : "New Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Add") { save() }
                        .disabled(!isValid)
                        .fontWeight(.semibold)
                }
            }
            .onAppear(perform: populateFields)
        }
    }

    private func populateFields() {
        guard let expense else { return }
        title = expense.title
        amountText = String(format: "%.2f", expense.amount)
        category = expense.category
        date = expense.date
        note = expense.note
    }

    private func save() {
        guard let amount = Double(amountText) else { return }

        if let expense {
            expense.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
            expense.amount = amount
            expense.category = category
            expense.date = date
            expense.note = note
        } else {
            let newExpense = Expense(
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                amount: amount,
                category: category,
                date: date,
                note: note
            )
            modelContext.insert(newExpense)
        }

        dismiss()
    }

    private func deleteExpense() {
        if let expense {
            modelContext.delete(expense)
        }
        dismiss()
    }
}

#Preview {
    AddEditExpenseView()
        .modelContainer(for: Expense.self, inMemory: true)
}
