//
//  CDAccountDAO.swift
//  Expenses
//
//  Created by Frank Mathy on 10.03.18.
//  Copyright © 2018 Frank Mathy. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CDAccountDAO {

    static let sharedInstance = CDAccountDAO()
    
    func create() -> Account? {
        let managedContext = CoreDataUtil.sharedInstance.managedObjectContext!
        return Account(context: managedContext)
    }
    
    func load() -> ([Account]?, Error?) {
        let managedContext = CoreDataUtil.sharedInstance.managedObjectContext!
        let accountFetch = NSFetchRequest<Account>(entityName: "Account")
        accountFetch.sortDescriptors = [NSSortDescriptor(key: "accountName", ascending: true)]
        do {
            let items = try managedContext.fetch(accountFetch)
            return (items, nil)
        } catch let error as NSError {
            print("Could not load. \(error), \(error.userInfo)")
            return (nil, error)
        }
    }
    
    func delete(account : Account) {
        let managedContext = CoreDataUtil.sharedInstance.managedObjectContext!
        managedContext.delete(account)
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not delete account. \(error), \(error.userInfo)")
        }
    }
}
