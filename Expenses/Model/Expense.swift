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
    
    struct ColumnKey {
        static let date = "Date"
        static let category = "Category"
        static let account = "Account"
        static let accountRef = "AccountRef"
        static let project = "Project"
        static let amount = "Amount"
        static let comment = "Comment"
    }
    
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
            return NamedItem(asCategory: record[ColumnKey.category] as! String)
        }
        
        set(newCategory) {
            record[ColumnKey.category] = newCategory.name as CKRecordValue
        }
    }
    
    var account: Account {
        get {
            return Account(byName: record[ColumnKey.account] as! String)
        }
        
        set(newAccount) {
            record[ColumnKey.account] = newAccount.name as CKRecordValue
        }
    }

    var accountRef: CKReference? {
        get {
            let accountRef = record[ColumnKey.accountRef]
            return accountRef as! CKReference?
        }
        
        set(newRef) {
            record[ColumnKey.accountRef] = newRef as! CKReference
        }
    }
    
    var project: NamedItem {
        get {
            return NamedItem(asProject: record[ColumnKey.project] as! String)
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
    
    var creatorUserRecordID : String? {
        guard let userRecordId = record.creatorUserRecordID else {
            return nil
        }
        return userRecordId.recordName
    }
    
    var creationDate : Date? {
        return record.creationDate
    }
    
    var lastModifiedUserRecordID : String? {
        guard let userRecordId = record.lastModifiedUserRecordID else {
            return nil
        }
        return userRecordId.recordName
    }
    
    var modificationDate : Date? {
        return record.modificationDate
    }
    
    init(date: Date, category: NamedItem, account: Account, project: NamedItem, amount: Float, comment: String) {
        record = CKRecord(recordType: Expense.RecordTypeName)
        self.date = date
        self.amount = amount
        self.category = category
        self.account = account
        self.project = project
        self.comment = comment
    }
    
    init(asNew record: CKRecord) {
        self.record = record
    }
    
    init(asCopy expense: Expense) {
        record = expense.record.copy() as! CKRecord
    }
    
    func asCKRecord() -> CKRecord {
        return record
    }
    
    func updateFromOtherExpense(other : Expense) {
        date = other.date
        category = other.category
        account = other.account
        project = other.project
        amount = other.amount
        comment = other.comment
    }
}
