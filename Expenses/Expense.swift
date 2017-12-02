//
//  Expense.swift
//  Expenses
//
//  Created by Frank Mathy on 26.11.17.
//  Copyright © 2017 Frank Mathy. All rights reserved.
//

import Foundation

struct Expense {
    var date: Date
    var category: Category
    var account: Account
    var project: Project
    var amount: Float
    var comment: String
    
    init(date: Date, category: Category, account: Account, project: Project, amount: Float, comment: String) {
        self.date = date
        self.category = category
        self.account = account
        self.project = project
        self.amount = amount
        self.comment = comment
    }
    
    init(byExpense expense: Expense) {
        self.init(date: expense.date, category: expense.category, account: expense.account, project: expense.project, amount: expense.amount, comment: "")
    }
}
