//
//  ExpenseDAO.swift
//  Expenses
//
//  Created by Frank Mathy on 22.12.17.
//  Copyright © 2017 Frank Mathy. All rights reserved.
//

import Foundation
import CloudKit

protocol ExpenseObserver {
    func expensesChanged(expenses: [Expense])
}

class ExpenseDAO {
    
    let container: CKContainer
    let publicDB: CKDatabase
    let cloudUserInfo: CloudUserInfo
    
    var observers = [ExpenseObserver]()
    
    init() {
        container = CKContainer.default()
        publicDB = container.publicCloudDatabase
        cloudUserInfo = CloudUserInfo()
        cloudUserInfo.loadUserInfo()
    }
    
    func addObserver(observer : ExpenseObserver) {
        observers.append(observer)
    }
    
    func observeExpenses() {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: Expense.RecordTypeName, predicate: predicate)
        publicDB.perform(query, inZoneWith: nil) { [unowned self] results,error in
            guard error == nil else {
                print("Cloud Query Error - Refresh: \(error)")
                return
            }
            var newExpenses: [Expense] = []
            for record in results! {
                let expense = Expense(record: record)
                newExpenses.append(expense)
            }
            DispatchQueue.main.async {
                for observer in self.observers {
                    observer.expensesChanged(expenses: newExpenses)
                }
            }
        }
    }
    
    func addExpense(expense: Expense) {
        publicDB.save(expense.asCKRecord(), completionHandler: { (record, error) in
            guard error == nil else {
                print("Error saving new expense record \(error)")
                return
            }
            expense.recordId = (record?.recordID)!
            print("Saved: \(record)")
        })
    }
    
    func updateExpense(expense: Expense) {
        addExpense(expense: expense)
    }
    
    func removeExpense(expense: Expense) {
        publicDB.delete(withRecordID: expense.recordId!) { (record, error) in
            guard error == nil else {
                print("Error deleting new expense record \(error)")
                return
            }
            print("Deleted: \(record)")
        }
    }
}
