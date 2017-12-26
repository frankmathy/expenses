//
//  Expense.swift
//  Expenses
//
//  Created by Frank Mathy on 26.11.17.
//  Copyright © 2017 Frank Mathy. All rights reserved.
//

import Foundation
import CloudKit

class Expense {
    var recordId: CKRecordID?
    var date: Date
    var category: NamedItem
    var account: NamedItem
    var project: NamedItem
    var amount: Float
    var comment: String
    
    static let RecordTypeName = "Expense"
    
    //MARK: Types
    struct ColumnKey {
        static let key = "key"
        static let date = "Date"
        static let category = "Category"
        static let account = "Account"
        static let project = "Project"
        static let amount = "Amount"
        static let comment = "Comment"
    }
    
    convenience init(date: Date, category: NamedItem, account: NamedItem, project: NamedItem, amount: Float, comment: String) {
        self.init(recordId: nil, date: date, category: category, account: account, project: project, amount: amount, comment: comment)
    }
    
    convenience init(expense: Expense) {
        self.init(recordId: expense.recordId, date: expense.date, category: expense.category, account: expense.account, project: expense.project, amount: expense.amount,comment: expense.comment)
    }
    
    init(recordId: CKRecordID?, date: Date, category: NamedItem, account: NamedItem, project: NamedItem, amount: Float, comment: String) {
        self.recordId = recordId
        self.date = date
        self.amount = amount
        self.category = category
        self.account = account
        self.project = project
        self.comment = comment
    }
    
    init(record: CKRecord) {
        self.recordId = record.recordID
        self.date = record[ColumnKey.date] as! Date
        self.category = NamedItem(name: record[ColumnKey.category] as! String)
        self.account = NamedItem(name: record[ColumnKey.account] as! String)
        self.project = NamedItem(name: record[ColumnKey.project] as! String)
        self.amount = record[ColumnKey.amount] as! Float
        self.comment = record[ColumnKey.comment] as! String
    }
    
    convenience init(byExpense expense: Expense) {
        self.init(date: expense.date, category: expense.category, account: expense.account, project: expense.project, amount: expense.amount, comment: "")
    }
    
    func asCKRecord() -> CKRecord {
        let record = recordId != nil ? CKRecord(recordType: Expense.RecordTypeName, recordID: recordId!) : CKRecord(recordType: Expense.RecordTypeName)
        record.setObject(date as CKRecordValue, forKey: ColumnKey.date)
        record.setObject(amount as CKRecordValue, forKey: ColumnKey.amount)
        record.setObject(category.name as CKRecordValue, forKey: ColumnKey.category)
        record.setObject(account.name as CKRecordValue, forKey: ColumnKey.account)
        record.setObject(project.name as CKRecordValue, forKey: ColumnKey.project)
        record.setObject(comment as CKRecordValue, forKey: ColumnKey.comment)
        return record
    }    
}
