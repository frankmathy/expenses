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
        return Expense(context: CoreDataUtil.sharedInstance.managedObjectContext!)
    }
    
    func load(dateIntervalSelection : DateIntervalSelection) -> (expenses: [Expense]?, error: NSError?) {
        let managedContext = CoreDataUtil.sharedInstance.managedObjectContext
        let expenseFetch = NSFetchRequest<Expense>(entityName: CDExpensesDAO.entityName)
        if dateIntervalSelection.dateIntervalType != DateIntervalType.All {
            expenseFetch.predicate = NSPredicate(format: "date >= %@ and date <= %@", dateIntervalSelection.startDate! as NSDate, dateIntervalSelection.endDate! as NSDate)
        }
        do {
            let items = try managedContext!.fetch(expenseFetch)
            return (items, nil)
        } catch let error as NSError {
            print("Could not load. \(error), \(error.userInfo)")
            return (nil, error)
        }
    }
    
    func delete(expense: Expense) -> NSError? {
        let managedContext = CoreDataUtil.sharedInstance.managedObjectContext!
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
        let managedContext = CoreDataUtil.sharedInstance.managedObjectContext!
        let expenseFetch = NSFetchRequest<Expense>(entityName: CDExpensesDAO.entityName)
        do {
            let expenses = try managedContext.fetch(expenseFetch)
            for expense in expenses {
                managedContext.delete(expense)
            }
            try managedContext.save()
            print("Deleted \(expenses.count) expenses")
        } catch let error as NSError {
            print("Error deletimg all expenses. \(error), \(error.userInfo)")
        }
    }
}
