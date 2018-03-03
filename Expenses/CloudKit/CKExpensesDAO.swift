//
//  CKExpensesDAO.swift
//  Expenses
//
//  Created by Frank Mathy on 03.03.18.
//  Copyright © 2018 Frank Mathy. All rights reserved.
//

import Foundation
import CloudKit

class CKExpensesDAO {

    static let sharedInstance = CKExpensesDAO()

    func load(dateIntervalSelection : DateIntervalSelection, completionHandler: @escaping ([Expense]?, Error?) -> Swift.Void) {
        let privateDB = CKContainer.default().privateCloudDatabase
        var datePredicate = NSPredicate(value: true)
        if dateIntervalSelection.dateIntervalType != DateIntervalType.All {
            datePredicate = NSPredicate(format: "Date >= %@ and Date <= %@", dateIntervalSelection.startDate! as NSDate, dateIntervalSelection.endDate! as NSDate)
        }
        let query = CKQuery(recordType: Expense.RecordTypeName, predicate: datePredicate)
        privateDB.perform(query, inZoneWith: nil) { [unowned self] results,error in
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            var expenses = [Expense]()
            for record in results! {
                if record.parent != nil {
                    let expense = Expense(asNew: record)
                    expenses.append(expense)
                }
            }
            completionHandler(expenses, nil)
        }
    }
    
    func save(expense: Expense, completionHandler: @escaping (Expense?, Error?) -> Swift.Void) {
        let privateDB = CKContainer.default().privateCloudDatabase
        privateDB.save(expense.record, completionHandler: { (record, error) in
            guard error == nil else {
                print("Error saving expense record with ID=\(record!.recordID): " + error.debugDescription)
                completionHandler(nil, error)
                return
            }
            print("Successfully saved expense with ID=\(record!.recordID)")
            completionHandler(expense, nil)
        })
    }
    
    func delete(expense: Expense, completionHandler: @escaping (Error?) -> Swift.Void) {
        let privateDB = CKContainer.default().privateCloudDatabase
        privateDB.delete(withRecordID: expense.record.recordID) { (record, error) in
            guard error == nil else {
                print("Error deleting expense record")
                completionHandler(error)
                return
            }
            print("Successfully deleted expense wth ID=\(expense.record.recordID)")
            completionHandler(nil)
        }
    }
}
