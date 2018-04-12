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
    
    static let entityName = "Expense"

    func create() -> Expense? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        let managedContext = appDelegate.persistentContainer.viewContext
        return Expense(context: managedContext)
    }
    
    func load(dateIntervalSelection : DateIntervalSelection) -> (expenses: [Expense]?, error: NSError?) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return (nil, nil) }
        let managedContext = appDelegate.persistentContainer.viewContext
        let expenseFetch = NSFetchRequest<Expense>(entityName: CDExpensesDAO.entityName)
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
    
    func cancelChanges() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        try managedContext.reset()
    }
    
    func delete(expense: Expense) -> NSError? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return NSError(domain: CDExpensesDAO.entityName, code: 1, userInfo: nil) }
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.delete(expense)
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not delete. \(error), \(error.userInfo)")
            return error
        }
        return nil
    }
    
    func deleteAll() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: CDExpensesDAO.entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try managedContext.execute(deleteRequest)
            try managedContext.save()
        }
        catch let error as NSError {
            print("Error deleting all expenses: \(error), \(error.userInfo)")
        }
    }
}
