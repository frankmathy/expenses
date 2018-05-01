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
    var totalsForKey = [ExpenseKey: Double]()
    var grandTotal : Double = 0.0
    
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
        expensesForKey[groupCategory]?.sort { ($0.date! as Date) > ($1.date! as Date) }
        totalsForKey[groupCategory] = totalsForKey[groupCategory]! + expense.amountAccountCcy!
        grandTotal = grandTotal + expense.amountAccountCcy!
    }
    
    func removeAll() {
        sortedGroupKeys.removeAll()
        expensesForKey.removeAll()
        totalsForKey.removeAll()
        grandTotal = 0.0
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
    
    func sectionCategoryKey(inSection: Int) -> ExpenseKey? {
        if inSection < sortedGroupKeys.count {
            return sortedGroupKeys[inSection]
        } else {
            return nil
        }
    }
    
    func sectionExpenses(inSection: Int) -> [Expense] {
        let key = sectionCategoryKey(inSection: inSection)
        if key != nil {
            return expensesForKey[sectionCategoryKey(inSection: inSection)!]!
        } else {
            return []
        }
    }
    
    func expensesCount(inSection: Int) -> Int {
        return sectionExpenses(inSection: inSection).count
    }
    
    func expense(inSection: Int, row: Int) -> Expense {
        return sectionExpenses(inSection: inSection)[row]
    }
    
    func removeExpense(inSection: Int, row: Int) {
        let key = sectionCategoryKey(inSection: inSection)
        if key != nil {
            let expenseAmount = expensesForKey[key!]![row].amountAccountCcy!
            totalsForKey[key!] = totalsForKey[key!]! - expenseAmount
            grandTotal = grandTotal - expenseAmount
            expensesForKey[key!]!.remove(at: row)
            if expensesForKey[key!]!.count == 0 {
                totalsForKey.removeValue(forKey: key!)
                expensesForKey.removeValue(forKey: key!)
                sortedGroupKeys.remove(at: inSection)
            }
        }
    }
    
    func totalAmount(forExpenseKey: ExpenseKey) -> Double {
        return totalsForKey[forExpenseKey]!
    }
    
    func totalAmount(inSection: Int) -> Double {
        return totalAmount(forExpenseKey: sectionCategoryKey(inSection: inSection)!)
    }
}
