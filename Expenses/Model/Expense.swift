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
        static let project = "Project"
        static let amount = "Amount"
        static let comment = "Comment"
        static let latitude = "Latitude"
        static let longitude = "Longitude"
    }
    
    var record : CKRecord
    
    private var accountObject : Account?
    
    var account : Account? {
        set(newAccount) {
            self.accountObject = newAccount
            if account != nil {
                self.accountReference = CKReference(recordID: account!.record.recordID, action: .none)
            } else {
                self.accountReference = nil
            }
        }
        
        get {
            return self.accountObject
        }
    }
    
    var accountName : String? {
        get {
            if account != nil {
                return account!.accountName
            } else {
                return nil
            }
        }
    }
    
    var accountReference : CKReference? {
        get {
            return record.parent
        }
        
        set(newRef) {
            record.parent = newRef
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
    
    var category: String {
        get {
            return record[ColumnKey.category] as! String
        }
        
        set(newCategory) {
            record[ColumnKey.category] = newCategory as CKRecordValue
        }
    }
    
    var project: String {
        get {
            return record[ColumnKey.project] as! String
        }
        
        set(newProject) {
            record[ColumnKey.project] = newProject as CKRecordValue
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
    
    var latitude: Double? {
        get {
            return record[ColumnKey.latitude] as! Double?
        }
        
        set(newValue) {
            record[ColumnKey.latitude] = newValue as CKRecordValue?
        }
    }
    
    var longitude: Double? {
        get {
            return record[ColumnKey.longitude] as! Double?
        }
        
        set(newValue) {
            record[ColumnKey.longitude] = newValue as CKRecordValue?
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
    
    init(date: Date, category: String, account: Account, project: String, amount: Float, comment: String) {
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
        account = expense.account
    }
    
    func updateFromOtherExpense(other : Expense) {
        date = other.date
        category = other.category
        accountReference = other.accountReference
        project = other.project
        amount = other.amount
        comment = other.comment
    }
}
