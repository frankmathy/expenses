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
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        let managedContext = appDelegate.persistentContainer.viewContext
        return Account(context: managedContext)
    }
    
    func load(completionHandler: @escaping ([Account]?, Error?) -> Swift.Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let accountFetch = NSFetchRequest<Account>(entityName: "Account")
        do {
            let items = try managedContext.fetch(accountFetch)
            completionHandler(items, nil)
        } catch let error as NSError {
            print("Could not load. \(error), \(error.userInfo)")
            completionHandler(nil, error)
        }
    }
    
    func save(account : Account, completionHandler: @escaping (Account?, Error?) -> Swift.Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}
