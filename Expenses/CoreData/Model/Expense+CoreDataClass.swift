//
//  Expense+CoreDataClass.swift
//  Expenses
//
//  Created by Frank Mathy on 01.05.18.
//  Copyright © 2018 Frank Mathy. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Expense)
public class Expense: NSManagedObject {
    var amountAccountCcy : Double? {
        get {
            let currency = self.currency
            let amount = self.amount
            if currency == nil || currency == SystemConfig.sharedInstance.appCurrencyCode {
                return amount
            } else {
                return amount != nil && exchangeRate != nil && exchangeRate != 0.0 ? amount * exchangeRate : amount
            }
        }
    }
}
