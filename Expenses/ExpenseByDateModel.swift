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
    var totalsForDate = [Date: Float]()
    
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
        if totalsForDate[groupDate] == nil {
            totalsForDate[groupDate] = 0.0
        }
        expensesAtDate[groupDate]?.append(expense)
        totalsForDate[groupDate] = totalsForDate[groupDate]! + expense.amount
    }
    
    func removeAll() {
        sortedExpenseDates.removeAll()
        expensesAtDate.removeAll()
        totalsForDate.removeAll()
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
    
    func totalAmount(forDate: Date) -> Float {
        return totalsForDate[forDate]!
    }
    
    func totalAmount(inSection: Int) -> Float {
        return totalAmount(forDate: sectionDate(inSection: inSection))
    }
}
