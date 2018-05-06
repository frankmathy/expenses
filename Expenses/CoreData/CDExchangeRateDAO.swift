//
//  CDExchangeRateDAO.swift
//  Expenses
//
//  Created by Frank Mathy on 06.05.18.
//  Copyright © 2018 Frank Mathy. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CDExchangeRateDAO {
    
    static let sharedInstance = CDExchangeRateDAO()
    
    func create() -> ExchangeRate? {
        let managedContext = CoreDataUtil.sharedInstance.managedObjectContext!
        return ExchangeRate(context: managedContext)
    }
    
    func get(baseCcy : String, termsCcy : String) -> (ExchangeRate?, Error?) {
        let managedContext = CoreDataUtil.sharedInstance.managedObjectContext!
        let rateFetch = NSFetchRequest<ExchangeRate>(entityName: "ExchangeRate")
        rateFetch.predicate = NSPredicate(format: "baseCcy = %@ and termsCcy = %@",baseCcy, termsCcy)
        rateFetch.sortDescriptors = [NSSortDescriptor(key: "recordDate", ascending: false)]
        do {
            let items = try managedContext.fetch(rateFetch)
            return (items.count > 0 ? items[0] : nil, nil)
        } catch let error as NSError {
            print("Could not load. \(error), \(error.userInfo)")
            return (nil, error)
        }
    }
    
    func delete(rate : ExchangeRate) {
        let managedContext = CoreDataUtil.sharedInstance.managedObjectContext!
        managedContext.delete(rate)
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not delete rate. \(error), \(error.userInfo)")
        }
    }
}
