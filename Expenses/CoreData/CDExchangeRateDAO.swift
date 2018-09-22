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
    
    static let ENTITY_NAME = "ExchangeRate"
    
    func get(byCcyPair baseCcy : String, termsCcy : String) -> (ExchangeRate?, Error?) {
        let managedContext = CoreDataUtil.sharedInstance.managedObjectContext!
        let rateFetch = NSFetchRequest<ExchangeRate>(entityName: CDExchangeRateDAO.ENTITY_NAME)
        rateFetch.predicate = NSPredicate(format: "baseCcy = %@ and termsCcy = %@ and active=TRUE",baseCcy, termsCcy)
        rateFetch.sortDescriptors = [NSSortDescriptor(key: "recordDate", ascending: false)]
        do {
            let items = try managedContext.fetch(rateFetch)
            return (items.count > 0 ? items[0] : nil, nil)
        } catch let error as NSError {
            print("Could not load. \(error), \(error.userInfo)")
            return (nil, error)
        }
    }
    
    func addCurrentRate(baseCcy : String, termsCcy : String, rateValue : Double) throws -> ExchangeRate {
        // Mark old rate as recent
        let managedContext = CoreDataUtil.sharedInstance.managedObjectContext!
        let rateFetch = NSFetchRequest<ExchangeRate>(entityName: CDExchangeRateDAO.ENTITY_NAME)
        rateFetch.predicate = NSPredicate(format: "baseCcy = %@ and termsCcy = %@ and active=TRUE",baseCcy, termsCcy)
        let oldRates = try managedContext.fetch(rateFetch)
        for oldRate in oldRates {
            oldRate.active = false
        }
        
        let rate = ExchangeRate(context: managedContext)
        rate.baseCcy = baseCcy
        rate.termsCcy = termsCcy
        rate.rate = rateValue
        rate.active = true
        rate.recordDate = GeneralUtils.removeTimeStamp(fromDate: Date())
        
        try managedContext.save()
        
        return rate
    }
    
    func removeAll() {
        let managedContext = CoreDataUtil.sharedInstance.managedObjectContext!
        let rateFetch = NSFetchRequest<ExchangeRate>(entityName: CDExchangeRateDAO.ENTITY_NAME)
        do {
            let items = try managedContext.fetch(rateFetch)
            for item in items {
                managedContext.delete(item)
            }
            try managedContext.save()
            print("All rates deleted")
        } catch let error as NSError {
            print("Could not delete all rates. \(error), \(error.userInfo)")
            return
        }
    }
}
