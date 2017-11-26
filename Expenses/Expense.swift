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
    var amount: Double
    var comment: String
    
    init(date: Date, category: Category, account: Account, amount: Double, comment: String) {
        self.date = date
        self.category = category
        self.account = account
        self.amount = amount
        self.comment = comment
    }
}
