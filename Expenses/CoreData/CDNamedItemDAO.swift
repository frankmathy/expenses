//
//  CDNamedItemDAO.swift
//  Expenses
//
//  Created by Frank Mathy on 10.03.18.
//  Copyright © 2018 Frank Mathy. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CDNamedItemDAO {
    
    static let sharedInstance = CDNamedItemDAO()

    func create() -> NamedItem? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        let managedContext = appDelegate.persistentContainer.viewContext
        return NamedItem(context: managedContext)
    }
    
    func save(item : NamedItem) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func load(itemType : String) -> ([NamedItem]?, Error?) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return (nil, nil) }
        let managedContext = appDelegate.persistentContainer.viewContext
        let namedItemFetch = NSFetchRequest<NamedItem>(entityName: "NamedItem")
        namedItemFetch.predicate = NSPredicate(format: "listName == %@", itemType)
        namedItemFetch.sortDescriptors = [NSSortDescriptor(key: "itemName", ascending: true)]
        do {
            let items = try managedContext.fetch(namedItemFetch)
            return (items, nil)
        } catch let error as NSError {
            print("Could not load. \(error), \(error.userInfo)")
            return (nil, error)
        }
    }
    
    func delete(item : NamedItem) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.delete(item)
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}
