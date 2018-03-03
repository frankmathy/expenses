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
    func modelUpdated()
    func dateIntervalChanged()
    func cloudAccessError(message: String, error: NSError)
}

class Model {
    
    static let sharedInstance = Model()

    var expenseByRecordId = [String : Expense]()
    let expenseByDateModel : (GroupedExpenseModel<Date>)?
    let expenseByCategoryModel : (GroupedExpenseModel<String>)?
    
    var ownAccountsByName = [String : Account]()
    var ownAccountsByRecordId = [String : Account]()

    let container: CKContainer
    let privateDB: CKDatabase
    let cloudUserInfo: CloudUserInfo
    
    let dateIntervalSelection = DateIntervalSelection()
    
    var delegates = [ModelDelegate]()
    
    init() {
        container = CKContainer.default()
        
        // Create model grouped by date
        expenseByDateModel = GroupedExpenseModel<Date>(getKeyFunction: { (expense) -> Date in
            Calendar.current.startOfDay(for: expense.date)
        }, compareKeysFunction: { (d1, d2) -> Bool in
            return d1.compare(d2) != ComparisonResult.orderedAscending
        })
        
        // Create model grouped by category
        expenseByCategoryModel = GroupedExpenseModel<String>(getKeyFunction: { (expense) -> String in
            expense.category
        }, compareKeysFunction: { (c1, c2) -> Bool in
            return c1.compare(c2) == ComparisonResult.orderedAscending
        })

        /* TODO Implement check if user is logged in to iCloud
        container.accountStatus(completionHandler: { (accountStatus, error) in
        }) */
        privateDB = container.privateCloudDatabase
        _ = dateIntervalSelection.setDateIntervalType(dateIntervalType: .Week)
        cloudUserInfo = CloudUserInfo()
    }
    
    func initializeStaticData(completionHandler: @escaping () -> Swift.Void) {
        cloudUserInfo.loadUserInfo()
        initializeSubscriptions()
        loadAccounts(completionHandler: completionHandler)
    }
    
    func loadAccounts(completionHandler: @escaping () -> Swift.Void) {
        let query = CKQuery(recordType: Account.RecordTypeName, predicate: NSPredicate(value: true))
        privateDB.perform(query, inZoneWith: nil) { (records, error) in
            guard error == nil else {
                let message = NSLocalizedString("Error loading accounts from iCloud", comment: "")
                self.cloudAccessError(message: message, error: error! as NSError)
                completionHandler()
                return
            }
            if records!.count > 0 {
                for record in records! {
                    let account = Account(asNew: record)
                    self.ownAccountsByName[account.accountName] = account
                    self.ownAccountsByRecordId[record.recordID.recordName] = account
                    completionHandler()
                }
            } else {
                self.createAccount(accountName: SampleData.accountHousehold, completionHandler: { (account, error) in
                    completionHandler()
                })
            }
        }
    }
    
    func getDefaultAccount() -> Account? {
        if ownAccountsByName.count > 0 {
            return (ownAccountsByName.first?.value)!
        } else {
            return nil
        }
    }
    
    func getAccount(recordName : String) -> Account? {
        return ownAccountsByRecordId[recordName]
    }
    
    func getAccounts() -> [Account] {
        return Array(ownAccountsByName.values)
    }
    
    func createAccount(accountName : String, completionHandler: @escaping (Account?, Error?) -> Swift.Void) {
        let account = Account(accountName: accountName)
        self.ownAccountsByName[account.accountName] = account
        self.ownAccountsByRecordId[account.record.recordID.recordName] = account
        privateDB.save(account.record) { (record, error) in
            guard error == nil else {
                let message = NSLocalizedString("Error saving new account \(accountName) to iCloud", comment: "")
                self.cloudAccessError(message: message, error: error! as NSError)
                completionHandler(account, error)
                return
            }
            completionHandler(account, error)
        }
    }
    
    fileprivate func initializeSubscriptions() {
        // Delete existing subscriptions
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
                self.cloudAccessError(message: message, error: error! as NSError)
            }
            if !isSubscribed {
                // Subscribe to all record changes
                let subscription = CKQuerySubscription(recordType: Expense.RecordTypeName, predicate: NSPredicate(value: true), options: [.firesOnRecordCreation, .firesOnRecordDeletion, .firesOnRecordUpdate])
                let notification = CKNotificationInfo()
                notification.alertBody = "Update in Expenses received."
                notification.soundName = "default"
                subscription.notificationInfo = notification
                self.privateDB.save(subscription) { result, error in
                    if error == nil{
                        print("Added subscription with id: \(subscription.subscriptionID)")
                    } else {
                        let message = NSLocalizedString("Error adding iCloud subscription", comment: "")
                        self.cloudAccessError(message: message, error: error! as NSError)
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
        for observer in self.delegates {
            observer.cloudAccessError(message: message, error: error)
        }
    }
    
    func modelUpdated() {
        for observer in self.delegates {
            observer.modelUpdated()
        }
    }
    
    func setDateIntervalType(dateIntervalType: DateIntervalType) {
        if dateIntervalSelection.setDateIntervalType(dateIntervalType: dateIntervalType) {
            for observer in self.delegates {
                observer.dateIntervalChanged()
            }
        }
    }
    
    func dateIntervalNext() {
        if dateIntervalSelection.dateIntervalType != DateIntervalType.All {
            dateIntervalSelection.nextInterval()
            for observer in self.delegates {
                observer.dateIntervalChanged()
            }
        }
    }
    
    func dateIntervalPrevious() {
        if dateIntervalSelection.dateIntervalType != DateIntervalType.All {
            dateIntervalSelection.previousInterval()
            for observer in self.delegates {
                observer.dateIntervalChanged()
            }
        }
    }
    
    func reloadExpenses() {
        var datePredicate = NSPredicate(value: true)
        if self.dateIntervalSelection.dateIntervalType != DateIntervalType.All {
            datePredicate = NSPredicate(format: "Date >= %@ and Date <= %@", self.dateIntervalSelection.startDate! as NSDate, self.dateIntervalSelection.endDate! as NSDate)
            //datePredicate = NSPredicate(format: "Date < %@", self.dateIntervalSelection.endDate as! NSDate)
        }
        let query = CKQuery(recordType: Expense.RecordTypeName, predicate: datePredicate)
        privateDB.perform(query, inZoneWith: nil) { [unowned self] results,error in
            guard error == nil else {
                let message = NSLocalizedString("Error loading expenses from iCloud", comment: "")
                self.cloudAccessError(message: message, error: error! as NSError)
                return
            }
            self.removeAllFromCollections()
            for record in results! {
                if record.parent != nil {
                    let expense = Expense(asNew: record)
                    let recordName = record.parent?.recordID.recordName
                    expense.account = self.getAccount(recordName: (recordName)!)
                    self.addExpenseToCollections(expense: expense)
                }
            }
            
            // Update models
            self.modelUpdated()
        }
    }
    
    private func removeAllFromCollections() {
        self.expenseByRecordId.removeAll()
        self.expenseByDateModel?.removeAll()
        self.expenseByCategoryModel?.removeAll()
    }
    
    private func addExpenseToCollections(expense : Expense) -> Void {
        self.expenseByRecordId[expense.record.recordID.recordName] = expense
        self.expenseByDateModel?.addExpense(expense: expense)
        self.expenseByCategoryModel?.addExpense(expense: expense)
    }
    
    // Add or update Expense
    func updateExpense(expense: Expense, isNewExpense: Bool, completionHandler: @escaping () -> Swift.Void) {
        let record: CKRecord = expense.record
        print("About to save expense with ID=\(record.recordID)")
        privateDB.save(record, completionHandler: { (record, error) in
            guard error == nil else {
                let message = NSLocalizedString("Error saving expense record", comment: "")
                self.cloudAccessError(message: message, error: error! as NSError)
                return
            }
            print("Successfully saved expense with ID=\(record!.recordID)")

            self.expenseByRecordId[expense.record.recordID.recordName] = expense
            if isNewExpense {
                self.expenseByDateModel?.addExpense(expense: expense)
                self.expenseByCategoryModel?.addExpense(expense: expense)
            } else {
                self.refreshExpenseModels()
            }
            completionHandler()
        })
    }
    
    func removeExpense(expense: Expense) {
        privateDB.delete(withRecordID: expense.record.recordID) { (record, error) in
            guard error == nil else {
                let message = NSLocalizedString("Error deleting expense record", comment: "")
                self.cloudAccessError(message: message, error: error! as NSError)
                return
            }
            print("Successfully deleted expense wth ID=\(expense.record.recordID)")
            self.expenseByRecordId.removeValue(forKey: expense.record.recordID.recordName)
            self.refreshExpenseModels()
            self.modelUpdated()
        }
    }
    
    func refreshExpenseModels() -> Void {
        self.expenseByDateModel?.removeAll()
        self.expenseByCategoryModel?.removeAll()
        for aExpense in self.expenseByRecordId.values {
            self.expenseByDateModel?.addExpense(expense: aExpense)
            self.expenseByCategoryModel?.addExpense(expense: aExpense)
        }
    }
    
    func addExpense(date: Date, categoryName : String, accountName : String, projectName: String, amount: Float, comment: String, completionHandler: @escaping () -> Swift.Void) {
        let account = getAccount(accountName: accountName)
        if account != nil {
            addExpense(date: date, categoryName: categoryName, account: account!, projectName: projectName, amount: amount, comment: comment, completionHandler: completionHandler)
        } else {
            createAccount(accountName: accountName, completionHandler: { (account, error) in
                guard error == nil else {
                    let message = NSLocalizedString("Error creating account in iCloud", comment: "")
                    self.cloudAccessError(message: message, error: error! as NSError)
                    return
                }
                self.addExpense(date: date, categoryName: categoryName, account: account!, projectName: projectName, amount: amount, comment: comment, completionHandler: completionHandler)
            })
        }
    }
    
    func addExpense(date: Date, categoryName : String, account : Account, projectName: String, amount: Float, comment: String, completionHandler: @escaping () -> Swift.Void) {
        let expense = Expense(date: date, category: categoryName, account: account, project: projectName, amount: amount, comment: comment)
        updateExpense(expense: expense, isNewExpense: true, completionHandler: completionHandler)
    }
        
    func getAccount(accountName : String) -> Account? {
        return ownAccountsByName[accountName]
    }
    
    func dateIntervalSelectionText() -> String {
        switch(dateIntervalSelection.dateIntervalType) {
        case .All:
            return NSLocalizedString("All", comment: "")
        case .Month:
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "MMMM yyyy"
            return dateFormat.string(from: Model.sharedInstance.dateIntervalSelection.startDate!)
        case .Year:
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "yyyy"
            return dateFormat.string(from: Model.sharedInstance.dateIntervalSelection.startDate!)
        case .Week:
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "dd.MM."
            let startDateString = dateFormat.string(from: Model.sharedInstance.dateIntervalSelection.startDate!)
            dateFormat.dateFormat = "dd.MM.yyyy"
            let endDateString = dateFormat.string(from: Model.sharedInstance.dateIntervalSelection.endDate!)
            return startDateString + "-" + endDateString
        }
    }
    
    func CSV() -> String {
        var csv = ""
        let dateFormat = ISO8601DateFormatter()
        for section in 0..<(expenseByDateModel!.sectionCount()) {
            for row in 0..<(expenseByDateModel!.expensesCount(inSection: section)) {
                let expense = expenseByDateModel!.expense(inSection: section, row: row)
                let dateString = dateFormat.string(from: expense.date)
                let amountString = String(expense.amount)
                csv += "\(dateString)\t\(amountString)\t\(expense.account!)\t\(expense.category)\t\(expense.project)\t\(expense.comment)\t \n"
            }
        }
        return csv
    }
}
