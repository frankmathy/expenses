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
    static let RecordTypeName = "Expense"
    
    var record : CKRecord
    
    var recordId: CKRecordID? {
        get {
            return record.recordID
        }
    }
    
    var date: Date {
        get {
            return record[ColumnKey.date] as! Date
        }
        
        set(newDate) {
            record[ColumnKey.date] = newDate as CKRecordValue
        }
    }
    
    var category: NamedItem {
        get {
            return NamedItem(name: record[ColumnKey.category] as! String)
        }
        
        set(newCategory) {
            record[ColumnKey.category] = newCategory.name as CKRecordValue
        }
    }
    
    var account: NamedItem {
        get {
            return NamedItem(name: record[ColumnKey.account] as! String)
        }
        
        set(newAccount) {
            record[ColumnKey.account] = newAccount.name as CKRecordValue
        }
    }
    
    var project: NamedItem {
        get {
            return NamedItem(name: record[ColumnKey.project] as! String)
        }
        
        set(newProject) {
            record[ColumnKey.project] = newProject.name as CKRecordValue
        }
    }
    
    var amount: Float {
        get {
            return record[ColumnKey.amount] as! Float
        }
        
        set(newAmount) {
            record[ColumnKey.amount] = newAmount as CKRecordValue
        }
    }
    
    var comment: String {
        get {
            return record[ColumnKey.comment] as! String
        }
        
        set(newComment) {
            record[ColumnKey.comment] = newComment as CKRecordValue
        }
    }
    
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
    
    init(date: Date, category: NamedItem, account: NamedItem, project: NamedItem, amount: Float, comment: String) {
        record = CKRecord(recordType: Expense.RecordTypeName)
        self.date = date
        self.amount = amount
        self.category = category
        self.account = account
        self.project = project
        self.comment = comment
    }
    
    init(record: CKRecord) {
        self.record = record
    }
    
    convenience init(byExpense expense: Expense) {
        self.init(date: expense.date, category: expense.category, account: expense.account, project: expense.project, amount: expense.amount, comment: expense.comment)
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
