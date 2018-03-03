//
//  CKSubscriptionManager.swift
//  Expenses
//
//  Created by Frank Mathy on 03.03.18.
//  Copyright © 2018 Frank Mathy. All rights reserved.
//

import Foundation
import CloudKit

class CKSubscriptionManager {
    
    static let sharedInstance = CKSubscriptionManager()
    
    func initializeSubscriptions(errorHandler: @escaping (Error, String) -> Swift.Void) {
        // Delete existing subscriptions
        let privateDB = CKContainer.default().privateCloudDatabase
        privateDB.fetchAllSubscriptions { [unowned self] subscriptions, error in
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
                errorHandler(error!, message)
            }
            if !isSubscribed {
                // Subscribe to all record changes
                let subscription = CKQuerySubscription(recordType: Expense.RecordTypeName, predicate: NSPredicate(value: true), options: [.firesOnRecordCreation, .firesOnRecordDeletion, .firesOnRecordUpdate])
                let notification = CKNotificationInfo()
                notification.alertBody = "Update in Expenses received."
                notification.soundName = "default"
                subscription.notificationInfo = notification
                privateDB.save(subscription) { result, error in
                    if error == nil{
                        print("Added subscription with id: \(subscription.subscriptionID)")
                    } else {
                        let message = NSLocalizedString("Error adding iCloud subscription", comment: "")
                        print("Error adding subscription with id \(subscription.subscriptionID): \(error!.localizedDescription)")
                        errorHandler(error!, message)
                    }
                }
            }
        }
    }
}
