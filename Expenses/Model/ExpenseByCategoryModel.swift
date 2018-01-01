//
//  ExpenseBeCategoryModel.swift
//  Expenses
//
//  Created by Frank Mathy on 01.01.18.
//  Copyright © 2018 Frank Mathy. All rights reserved.
//

import Foundation

class ExpenseByCategoryModel {
    
    var sortedCategories = [String]()
    var expensesOfCategory = [String: [Expense]]()
    var totalsForCategory = [String: Float]()
    var grandTotal : Float = 0.0
    
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
        let groupCategory = expense.category.name
        if expensesOfCategory[groupCategory] == nil {
            expensesOfCategory[groupCategory] = [Expense]()
            sortedCategories = Array(expensesOfCategory.keys)
            sortedCategories.sort()
        }
        if totalsForCategory[groupCategory] == nil {
            totalsForCategory[groupCategory] = 0.0
        }
        expensesOfCategory[groupCategory]?.append(expense)
        expensesOfCategory[groupCategory]?.sort { $0.date > $1.date }
        totalsForCategory[groupCategory] = totalsForCategory[groupCategory]! + expense.amount
        grandTotal = grandTotal + expense.amount
    }
    
    func removeAll() {
        sortedCategories.removeAll()
        expensesOfCategory.removeAll()
        totalsForCategory.removeAll()
    }
    
    func setExpenses(expenses: [Expense]) {
        removeAll()
        grandTotal = 0.0
        for expense in expenses {
            addExpense(expense: expense)
        }
    }
    
    func sectionCount() -> Int {
        return expensesOfCategory.keys.count
    }
    
    func sectionCategoryName(inSection: Int) -> String {
        return sortedCategories[inSection]
    }
    
    func sectionExpenses(inSection: Int) -> [Expense] {
        return expensesOfCategory[sectionCategoryName(inSection: inSection)]!
    }
    
    func expensesCount(inSection: Int) -> Int {
        return sectionExpenses(inSection: inSection).count
    }
    
    func expense(inSection: Int, row: Int) -> Expense {
        return sectionExpenses(inSection: inSection)[row]
    }
    
    func removeExpense(inSection: Int, row: Int) {
        let date = sectionCategoryName(inSection: inSection)
        let expenseAmount = expensesOfCategory[date]![row].amount
        totalsForCategory[date] = totalsForCategory[date]! - expenseAmount
        grandTotal = grandTotal - expenseAmount
        expensesOfCategory[date]!.remove(at: row)
        if expensesOfCategory[date]!.count == 0 {
            totalsForCategory.removeValue(forKey: date)
            expensesOfCategory.removeValue(forKey: date)
            sortedCategories.remove(at: inSection)
        }
    }
    
    func totalAmount(forCategoryName: String) -> Float {
        return totalsForCategory[forCategoryName]!
    }
    
    func totalAmount(inSection: Int) -> Float {
        return totalAmount(forCategoryName: sectionCategoryName(inSection: inSection))
    }
}
