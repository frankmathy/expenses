//
//  CDExpensesDAO.swift
//  Expenses
//
//  Created by Frank Mathy on 10.03.18.
//  Copyright © 2018 Frank Mathy. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CDExpensesDAO {
    
    static let sharedInstance = CDExpensesDAO()

    func create() -> Expense? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        let managedContext = appDelegate.persistentContainer.viewContext
        return Expense(context: managedContext)
    }
    
    func load(dateIntervalSelection : DateIntervalSelection) -> (expenses: [Expense]?, error: NSError?) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return (nil, nil) }
        let managedContext = appDelegate.persistentContainer.viewContext
        let expenseFetch = NSFetchRequest<Expense>(entityName: "Expense")
        if dateIntervalSelection.dateIntervalType != DateIntervalType.All {
            expenseFetch.predicate = NSPredicate(format: "date >= %@ and date <= %@", dateIntervalSelection.startDate! as NSDate, dateIntervalSelection.endDate! as NSDate)
        }
        do {
            let items = try managedContext.fetch(expenseFetch)
            return (items, nil)
        } catch let error as NSError {
            print("Could not load. \(error), \(error.userInfo)")
            return (nil, error)
        }
    }
    
    func save(expense: Expense, completionHandler: @escaping (Expense?, Error?) -> Swift.Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func cancelChanges() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        do {
            try managedContext.reset()
        } catch let error as NSError {
            print("Could not cancel. \(error), \(error.userInfo)")
        }
    }
    
    func delete(expense: Expense, completionHandler: @escaping (Error?) -> Swift.Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.delete(expense)
        do {
            try managedContext.save()
            completionHandler(nil)
        } catch let error as NSError {
            print("Could not delete. \(error), \(error.userInfo)")
            completionHandler(error)
        }
    }
}
