//
//  ExpenseDAO.swift
//  Expenses
//
//  Created by Frank Mathy on 22.12.17.
//  Copyright © 2017 Frank Mathy. All rights reserved.
//

import Foundation
import CoreData

protocol ModelDelegate {
    func modelUpdated()
    func dateIntervalChanged()
    func cloudAccessError(message: String, error: NSError)
}

class Model {
    
    static let sharedInstance = Model()

    let expenseByDateModel : (GroupedExpenseModel<Date>)?
    let expenseByCategoryModel : (GroupedExpenseModel<String>)?
    
    var ownAccountsByName = [String : Account]()
    var ownAccountsByRecordId = [NSManagedObjectID : Account]()

    var cloudUserInfo: CloudUserInfo?
    var userInfoByRecordName = [String : CloudUserInfo]()
    
    let dateIntervalSelection = DateIntervalSelection()
    
    var delegates = [ModelDelegate]()
    
    init() {
        // Create model grouped by date
        expenseByDateModel = GroupedExpenseModel<Date>(getKeyFunction: { (expense) -> Date in
            Calendar.current.startOfDay(for: expense.date!)
        }, compareKeysFunction: { (d1, d2) -> Bool in
            return d1.compare(d2) != ComparisonResult.orderedAscending
        })
        
        // Create model grouped by category
        expenseByCategoryModel = GroupedExpenseModel<String>(getKeyFunction: { (expense) -> String in
            expense.category!
        }, compareKeysFunction: { (c1, c2) -> Bool in
            return c1.compare(c2) == ComparisonResult.orderedAscending
        })

        _ = dateIntervalSelection.setDateIntervalType(dateIntervalType: .Week)
    }
    
    func loadAccounts() {
        ownAccountsByName.removeAll()
        ownAccountsByRecordId.removeAll()
        let (accounts, error) = CDAccountDAO.sharedInstance.load()
        guard error == nil else {
            let message = NSLocalizedString("Error loading accounts", comment: "")
            self.cloudAccessError(message: message, error: error! as NSError)
            return
        }
        if accounts != nil && (accounts?.count != 0) {
            for account in accounts! {
                self.ownAccountsByName[account.accountName!] = account
                self.ownAccountsByRecordId[account.objectID] = account
            }
        } else {
            let accountNames = PListUtils.loadDefaultValues(forResource: "DefaultValues", itemId: "accounts")
            if accountNames != nil {
                for accountName in accountNames! {
                    _ = createAccount(accountName: accountName)
                }
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
    
    func getAccount(recordName : NSManagedObjectID) -> Account? {
        return ownAccountsByRecordId[recordName]
    }
    
    func getAccounts() -> [Account] {
        return Array(ownAccountsByName.values)
    }
    
    func createAccount(accountName : String) -> (Account?, Error?) {
        let config = SystemConfig.sharedInstance
        
        let account = CDAccountDAO.sharedInstance.create()
        account?.accountName = accountName
        account?.currencyCode = config.appCurrencyCode
        account?.currencySymbol = config.appCurrencySymbol
        
        self.ownAccountsByName[account!.accountName!] = account
        self.ownAccountsByRecordId[account!.objectID] = account
        let error = CoreDataUtil.sharedInstance.saveChanges()
        guard error == nil else {
            let message = NSLocalizedString("Error saving new account \(accountName)", comment: "")
            self.cloudAccessError(message: message, error: error! as NSError)
            return (account, error)
        }
        return (account, error)
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
    
    func setDateToday() {
        dateIntervalSelection.setDateToday()
        for observer in self.delegates {
            observer.dateIntervalChanged()
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
        let (expenses, error) = CDExpensesDAO.sharedInstance.load(dateIntervalSelection: self.dateIntervalSelection)
        if error != nil {
            let message = NSLocalizedString("Error loading expenses from CoreData", comment: "")
            self.cloudAccessError(message: message, error: error! as NSError)
            return
        }
        
        self.removeAllFromCollections()
        for expense in expenses! {
            self.addExpenseToCollections(expense: expense)
            /* TODO if let parent = expense.record.parent {
                expense.account = self.getAccount(recordName: parent.recordID.recordName)
            }*/
        }
        
        // Update models
        self.modelUpdated()
    }
    
    private func removeAllFromCollections() {
        self.expenseByDateModel?.removeAll()
        self.expenseByCategoryModel?.removeAll()
    }
    
    private func addExpenseToCollections(expense : Expense) -> Void {
        self.expenseByDateModel?.addExpense(expense: expense)
        self.expenseByCategoryModel?.addExpense(expense: expense)
    }
    
    // Add or update Expense
    func updateExpense(expense: Expense, isNewExpense: Bool) {
        let error = CoreDataUtil.sharedInstance.saveChanges()
        guard error == nil else {
            let message = NSLocalizedString("Error saving expense record", comment: "")
            self.cloudAccessError(message: message, error: error! as NSError)
            return
        }
        reloadExpenses()
    }
    
    func removeExpense(expense: Expense) {
        let error = CDExpensesDAO.sharedInstance.delete(expense: expense)
        guard error == nil else {
            let message = NSLocalizedString("Error deleting expense record", comment: "")
            self.cloudAccessError(message: message, error: error!)
            return
        }
        print("Successfully deleted expense wth ID=\(expense.objectID)")
        reloadExpenses()
    }
    
    func deleteAllExpenses() {
        CDExpensesDAO.sharedInstance.deleteAll()
        reloadExpenses()
    }
    
    /* TODO
    func getUserInfo(recordName : String, completionHandler: @escaping (CloudUserInfo?, Error?) -> Swift.Void) {
        let info = userInfoByRecordName[recordName]
        if info != nil {
            completionHandler(info, nil)
        } else {
            CKUserDAO.sharedInstance.getUserInfo(recordName: recordName) { (userInfo, error) in
                if error == nil && userInfo != nil {
                    self.userInfoByRecordName[recordName] = userInfo
                }
                completionHandler(userInfo, error)
            }
        }
    }*/

    func addExpense(date: Date, categoryName : String, accountName : String, projectName: String, amount: Double, comment: String, venueId: String?, venueName: String?, venueLat: Double, venueLng: Double) {
        let account = getAccount(accountName: accountName)
        if account != nil {
            addExpense(date: date, categoryName: categoryName, account: account!, projectName: projectName, amount: amount, comment: comment, venueId: venueId, venueName: venueName, venueLat: venueLat, venueLng: venueLng)
        } else {
            let (account, error) = createAccount(accountName: accountName)
            guard error == nil else {
                let message = NSLocalizedString("Error creating account", comment: "")
                self.cloudAccessError(message: message, error: error! as NSError)
                return
            }
            self.addExpense(date: date, categoryName: categoryName, account: account!, projectName: projectName, amount: amount, comment: comment, venueId: venueId, venueName: venueName, venueLat: venueLat, venueLng: venueLng)
        }
    }
    
    func addExpense(date: Date, categoryName : String, account : Account, projectName: String, amount: Double, comment: String, venueId: String?, venueName: String?, venueLat: Double, venueLng: Double) {
        let expense = CDExpensesDAO.sharedInstance.create()
        expense?.date = date
        expense?.category = categoryName
        expense?.account = account
        expense?.project = projectName
        expense?.amount = amount
        expense?.comment = comment
        expense?.venueId = venueId
        expense?.venueName = venueName
        expense?.venueLat = venueLat
        expense?.venueLng = venueLng
        updateExpense(expense: expense!, isNewExpense: true)
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
                let dateString = dateFormat.string(from: expense.date!)
                let amountString = String(expense.amount)
                var venueLatString : String? = nil
                var venueLngString : String? = nil
                if expense.venueId != nil {
                    venueLatString = String(expense.venueLat)
                    venueLngString = String(expense.venueLng)
                }
                csv += "\(dateString)\t\(amountString)\t\(csvString(string: expense.account!.accountName))\t\(csvString(string: expense.category!))\t\(csvString(string: expense.project!))\t\(csvString(string: expense.comment!))\t\(csvString(string: expense.venueId))\t\(csvString(string: expense.venueName))\t\(csvString(string: venueLatString))\t\(csvString(string: venueLngString))\n"
            }
        }
        return csv
    }
    
    func csvString(string : String?) -> String {
        return string != nil ? string! : ""
    }
}
