//
//  ExpenseDAO.swift
//  Expenses
//
//  Created by Frank Mathy on 22.12.17.
//  Copyright © 2017 Frank Mathy. All rights reserved.
//

import Foundation
import CloudKit

protocol ModelDelegate {
    func modelUpdated(expenses: [Expense])
    func cloudAccessError(message: String, error: NSError)
}

class Model {
    
    static let sharedInstance = Model()
    
    let container: CKContainer
    let publicDB: CKDatabase
    let cloudUserInfo: CloudUserInfo
    
    var delegates = [ModelDelegate]()
    

    init() {
        container = CKContainer.default()
        publicDB = container.publicCloudDatabase
        cloudUserInfo = CloudUserInfo()
        cloudUserInfo.loadUserInfo()
        initializeSubscriptions()
    }
    
    fileprivate func initializeSubscriptions() {
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
                let message = NSLocalizedString("Error reading iCloud subscriptions", comment: "")
                self.cloudAccessError(message: message, error: error as! NSError)
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
                        let message = NSLocalizedString("Error adding iCloud subscription", comment: "")
                        self.cloudAccessError(message: message, error: error as! NSError)
                        print("Error adding subscription with id \(subscription.subscriptionID): \(error!.localizedDescription)")
                    }
                }
            }
        }
    }
    
    
    func addObserver(observer : ModelDelegate) {
        delegates.append(observer)
    }
    
    func cloudAccessError(message: String, error: NSError) {
        DispatchQueue.main.async {
            print("\(message): \(error)")
            for observer in self.delegates {
                observer.cloudAccessError(message: message, error: error)
            }
        }
    }
    
    fileprivate func modelUpdated(_ newExpenses: [Expense]) {
        DispatchQueue.main.async {
            for observer in self.delegates {
                observer.modelUpdated(expenses: newExpenses)
            }
        }
    }
    
    func reloadExpenses() {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: Expense.RecordTypeName, predicate: predicate)
        publicDB.perform(query, inZoneWith: nil) { [unowned self] results,error in
            guard error == nil else {
                let message = NSLocalizedString("Error loading expenses from iCloud", comment: "")
                self.cloudAccessError(message: message, error: error as! NSError)
                return
            }
            var newExpenses: [Expense] = []
            for record in results! {
                let expense = Expense(record: record)
                newExpenses.append(expense)
            }
            self.modelUpdated(newExpenses)
        }
    }
    
    func addExpense(expense: Expense) {
        let record: CKRecord = expense.asCKRecord()
        print("About to save expense with ID=\(record.recordID)")
        publicDB.save(record, completionHandler: { (record, error) in
            guard error == nil else {
                let message = NSLocalizedString("Error saving expense record", comment: "")
                self.cloudAccessError(message: message, error: error as! NSError)
                return
            }
            expense.recordId = (record?.recordID)!
            print("Successfully saved expense with ID=\(record?.recordID)")
        })
    }
    
    func updateExpense(expense: Expense) {
        addExpense(expense: expense)
    }
    
    func removeExpense(expense: Expense) {
        publicDB.delete(withRecordID: expense.recordId!) { (record, error) in
            guard error == nil else {
                let message = NSLocalizedString("Error deleting expense record", comment: "")
                self.cloudAccessError(message: message, error: error as! NSError)
                return
            }
            print("Successfully deleted expense wth ID=\(expense.recordId)")
        }
    }
}
