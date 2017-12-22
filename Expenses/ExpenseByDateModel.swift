//
//  ExpenseByDateModel.swift
//  Expenses
//
//  Created by Frank Mathy on 22.12.17.
//  Copyright © 2017 Frank Mathy. All rights reserved.
//

import Foundation

class ExpenseByDateModel {
    
    var sortedExpenseDates = [Date]()
    var expensesAtDate = [Date: [Expense]]()
    
    typealias PureDate = (day: Int, month: Int, year: Int)
    
    func dateWithoutTime(date : Date) -> Date {
        return Calendar.current.startOfDay(for: date)
    }
    
    init() {
    }
    
    init(expenses : [Expense]) {
        setExpenses(expenses: expenses)
    }
    
    func addExpense(expense : Expense) {
        let groupDate = dateWithoutTime(date: expense.date)
        if expensesAtDate[groupDate] == nil {
            expensesAtDate[groupDate] = [Expense]()
            sortedExpenseDates = Array(expensesAtDate.keys).sorted().reversed()
        }
        expensesAtDate[groupDate]?.append(expense)
    }
    
    func removeAll() {
        sortedExpenseDates.removeAll()
        expensesAtDate.removeAll()
    }
    
    func setExpenses(expenses: [Expense]) {
        removeAll()
        for expense in expenses {
            addExpense(expense: expense)
        }
    }
    
    func sectionCount() -> Int {
        return expensesAtDate.keys.count
    }
    
    func sectionDate(inSection: Int) -> Date {
        return sortedExpenseDates[inSection]
    }
    
    func sectionExpenses(inSection: Int) -> [Expense] {
        return expensesAtDate[sectionDate(inSection: inSection)]!
    }

    func expensesCount(inSection: Int) -> Int {
        return sectionExpenses(inSection: inSection).count
    }
    
    func expense(inSection: Int, row: Int) -> Expense {
        return sectionExpenses(inSection: inSection)[row]
    }
}
