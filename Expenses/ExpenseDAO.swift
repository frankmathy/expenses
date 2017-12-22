//
//  ExpenseDAO.swift
//  Expenses
//
//  Created by Frank Mathy on 22.12.17.
//  Copyright © 2017 Frank Mathy. All rights reserved.
//

import Foundation
import Firebase

protocol ExpenseObserver {
    func expensesChanged(expenses: [Expense])
}

class ExpenseDAO {
    
    let expensesDBReference : DatabaseReference
    
    var observers = [ExpenseObserver]()
    
    init() {
        expensesDBReference = Database.database().reference(withPath: "expenses")
    }
    
    func addObserver(observer : ExpenseObserver) {
        observers.append(observer)
    }
    
    func observeExpenses() {
        expensesDBReference.removeAllObservers()
        expensesDBReference.observe(.value, with: { (snapshot) in
            var newExpenses: [Expense] = []
            for entry in snapshot.children {
                let expense = Expense(snapshot: entry as! DataSnapshot)
                newExpenses.append(expense)
            }
            for observer in self.observers {
                observer.expensesChanged(expenses: newExpenses)
            }
        })
    }
    
    func addExpense(expense: Expense) {
        let newExpenseRef = expensesDBReference.childByAutoId()
        expense.key = newExpenseRef.key
        newExpenseRef.setValue(expense.toAnyObject())
    }
    
    func updateExpense(expense: Expense) {
        let expenseRef = expensesDBReference.child(expense.key)
        expenseRef.setValue(expense.toAnyObject())
    }
    
    func removeExpense(expense: Expense) {
        expensesDBReference.child(expense.key).removeValue()
    }
}
