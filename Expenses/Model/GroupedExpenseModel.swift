//
//  GroupedExpenseModel.swift
//  Generic class for storing data
//  Expenses
//
//  Created by Frank Mathy on 01.01.18.
//  Copyright © 2018 Frank Mathy. All rights reserved.
//

import Foundation

class GroupedExpenseModel<ExpenseKey : Hashable> {
    
    var sortedGroupKeys = [ExpenseKey]()
    var expensesForKey = [ExpenseKey: [Expense]]()
    var totalsForKey = [ExpenseKey: Float]()
    var grandTotal : Float = 0.0
    
    var getKeyFunction : ((Expense) -> ExpenseKey)
    var compareKeysFunction : (ExpenseKey, ExpenseKey) -> Bool
    
    init(getKeyFunction : @escaping (Expense) -> ExpenseKey, compareKeysFunction: @escaping (ExpenseKey, ExpenseKey) -> Bool) {
        self.getKeyFunction = getKeyFunction
        self.compareKeysFunction = compareKeysFunction
    }
    
    init(expenses : [Expense], getKeyFunction : @escaping (Expense) -> ExpenseKey, compareKeysFunction: @escaping (ExpenseKey, ExpenseKey) -> Bool) {
        self.getKeyFunction = getKeyFunction
        self.compareKeysFunction = compareKeysFunction
        setExpenses(expenses: expenses)
    }
    
    func addExpense(expense : Expense) {
        let groupCategory = getKeyFunction(expense)
        if expensesForKey[groupCategory] == nil {
            expensesForKey[groupCategory] = [Expense]()
            sortedGroupKeys = Array(expensesForKey.keys)
            sortedGroupKeys.sort(by: { (expenseKey1, expenseKey2) -> Bool in
                return compareKeysFunction(expenseKey1, expenseKey2)
            })
        }
        if totalsForKey[groupCategory] == nil {
            totalsForKey[groupCategory] = 0.0
        }
        expensesForKey[groupCategory]?.append(expense)
        expensesForKey[groupCategory]?.sort { $0.date > $1.date }
        totalsForKey[groupCategory] = totalsForKey[groupCategory]! + expense.amount
        grandTotal = grandTotal + expense.amount
    }
    
    func removeAll() {
        sortedGroupKeys.removeAll()
        expensesForKey.removeAll()
        totalsForKey.removeAll()
    }
    
    func setExpenses(expenses: [Expense]) {
        removeAll()
        grandTotal = 0.0
        for expense in expenses {
            addExpense(expense: expense)
        }
    }
    
    func sectionCount() -> Int {
        return expensesForKey.keys.count
    }
    
    func sectionCategoryKey(inSection: Int) -> ExpenseKey {
        return sortedGroupKeys[inSection]
    }
    
    func sectionExpenses(inSection: Int) -> [Expense] {
        return expensesForKey[sectionCategoryKey(inSection: inSection)]!
    }
    
    func expensesCount(inSection: Int) -> Int {
        return sectionExpenses(inSection: inSection).count
    }
    
    func expense(inSection: Int, row: Int) -> Expense {
        return sectionExpenses(inSection: inSection)[row]
    }
    
    func removeExpense(inSection: Int, row: Int) {
        let key = sectionCategoryKey(inSection: inSection)
        let expenseAmount = expensesForKey[key]![row].amount
        totalsForKey[key] = totalsForKey[key]! - expenseAmount
        grandTotal = grandTotal - expenseAmount
        expensesForKey[key]!.remove(at: row)
        if expensesForKey[key]!.count == 0 {
            totalsForKey.removeValue(forKey: key)
            expensesForKey.removeValue(forKey: key)
            sortedGroupKeys.remove(at: inSection)
        }
    }
    
    func totalAmount(forExpenseKey: ExpenseKey) -> Float {
        return totalsForKey[forExpenseKey]!
    }
    
    func totalAmount(inSection: Int) -> Float {
        return totalAmount(forExpenseKey: sectionCategoryKey(inSection: inSection))
    }
}