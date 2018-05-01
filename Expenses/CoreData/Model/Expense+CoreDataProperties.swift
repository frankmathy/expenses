//
//  Expense+CoreDataProperties.swift
//  Expenses
//
//  Created by Frank Mathy on 01.05.18.
//  Copyright © 2018 Frank Mathy. All rights reserved.
//
//

import Foundation
import CoreData


extension Expense {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Expense> {
        return NSFetchRequest<Expense>(entityName: "Expense")
    }

    @NSManaged public var amount: Double
    @NSManaged public var exchangeRate: Double
    @NSManaged public var category: String?
    @NSManaged public var comment: String?
    @NSManaged public var currency: String?
    @NSManaged public var date: NSDate?
    @NSManaged public var project: String?
    @NSManaged public var venueId: String?
    @NSManaged public var venueLat: Double
    @NSManaged public var venueLng: Double
    @NSManaged public var venueName: String?
    @NSManaged public var account: Account?

}
