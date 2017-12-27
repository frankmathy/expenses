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
        
        // Delete existing subscriptions
        publicDB.fetchAllSubscriptions { [unowned self] subscriptions, error in
            var isSubscribed = false
            if error == nil {
                if let subscriptions = subscriptions {
                    for subscription in subscriptions {
                        if subscription.recordType == Expense.RecordTypeName {
                            print("Existing subscription found with id: \(subscription.subscriptionID)")
                            isSubscribed = true
                            break
                        }
                    }
                }
            } else {
                // do your error handling here!
                print("Error reading existing subscriptions: \(error!.localizedDescription)")
                print(error!.localizedDescription)
            }
            if !isSubscribed {
                // Subscribe to all record changes
                let predicate = NSPredicate(value: true)
                let subscription = CKQuerySubscription(recordType: Expense.RecordTypeName, predicate: predicate, options: [.firesOnRecordCreation, .firesOnRecordDeletion, .firesOnRecordUpdate])
                let notification = CKNotificationInfo()
                notification.alertBody = "Update in Expenses received."
                notification.soundName = "default"
                subscription.notificationInfo = notification
                self.publicDB.save(subscription) { result, error in
                    if error == nil{
                        print("Added subscription with id: \(subscription.subscriptionID)")
                    } else {
                        print("Error adding subscription with id \(subscription.subscriptionID): \(error!.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func addObserver(observer : ExpenseObserver) {
        observers.append(observer)
    }
    
    func reloadExpenses() {
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
