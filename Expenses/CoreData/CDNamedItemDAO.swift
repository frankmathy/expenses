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
        return NamedItem(context: CoreDataUtil.sharedInstance.managedObjectContext!)
    }
    
    func load(itemType : String) -> ([NamedItem]?, Error?) {
        let managedContext = CoreDataUtil.sharedInstance.managedObjectContext!
        let namedItemFetch = NSFetchRequest<NamedItem>(entityName: "NamedItem")
        namedItemFetch.predicate = NSPredicate(format: "listName == %@", itemType)
        namedItemFetch.sortDescriptors = [NSSortDescriptor(key: "itemName", ascending: true)]
        do {
            var items = try managedContext.fetch(namedItemFetch)
            
            // If not available, load defaults if available
            if items.count == 0 {
                // Initialize with default values
                let itemStrings = PListUtils.loadDefaultValues(forResource: "DefaultValues", itemId: itemType)
                if itemStrings != nil {
                    for itemString in itemStrings! {
                        let newItem = CDNamedItemDAO.sharedInstance.create()
                        newItem?.itemName = itemString
                        newItem?.listName = itemType
                        items.append(newItem!)
                    }
                    do {
                        try CoreDataUtil.sharedInstance.saveChanges()
                    } catch {
                        // TODO Error handling
                        print("Error saving named item: \(error.localizedDescription)")
                    }
                }
            }
            
            return (items, nil)
        } catch let error as NSError {
            print("Could not load. \(error), \(error.userInfo)")
            return (nil, error)
        }
    }
    
    func delete(item : NamedItem) {
        let managedContext = CoreDataUtil.sharedInstance.managedObjectContext
        managedContext!.delete(item)
        do {
            try managedContext!.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}
