//
//  Expense.swift
//  Expenses
//
//  Created by Frank Mathy on 26.11.17.
//  Copyright © 2017 Frank Mathy. All rights reserved.
//

import Foundation
import os.log

class Expense: NSObject, NSCoding {
    var date: Date
    var category: Category
    var account: Account
    var project: Project
    var amount: Float
    var comment: String
    
    //MARK: Types
    struct PropertyKey {
        static let date = "date"
        static let category = "category"
        static let account = "account"
        static let project = "project"
        static let amount = "amount"
        static let comment = "comment"
    }
    
    init(date: Date, category: Category, account: Account, project: Project, amount: Float, comment: String) {
        self.date = date
        self.amount = amount
        self.category = category
        self.account = account
        self.project = project
        self.comment = comment
    }
    
    convenience init(byExpense expense: Expense) {
        self.init(date: expense.date, category: expense.category, account: expense.account, project: expense.project, amount: expense.amount, comment: "")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(date, forKey: PropertyKey.date)
        aCoder.encode(amount, forKey: PropertyKey.amount)
        aCoder.encode(category, forKey: PropertyKey.category)
        aCoder.encode(account, forKey: PropertyKey.account)
        aCoder.encode(project, forKey: PropertyKey.project)
        aCoder.encode(comment, forKey: PropertyKey.comment)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let date = aDecoder.decodeObject(forKey: PropertyKey.date) as? Date
        let amount = aDecoder.decodeFloat(forKey: PropertyKey.amount)
        let category = aDecoder.decodeObject(forKey: PropertyKey.category) as? Category
        let account = aDecoder.decodeObject(forKey: PropertyKey.account) as? Account
        let project = aDecoder.decodeObject(forKey: PropertyKey.project) as? Project
        let comment = aDecoder.decodeObject(forKey: PropertyKey.comment) as? String
        self.init(date: date!, category: category!, account: account!, project: project!, amount: amount, comment: comment!)
    }

}
