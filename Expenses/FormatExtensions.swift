//
//  FormatExtensions.swift
//  Expenses
//
//  Created by Frank Mathy on 26.11.17.
//  Copyright © 2017 Frank Mathy. All rights reserved.
//

import Foundation

// Formatting extensions for Date
extension Date {
    var asLocaleDateTimeString:String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale.current
        return dateFormatter.string(from: self)
    }
    
    var asLocaleDateString:String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale.current
        return dateFormatter.string(from: self)
    }
}

// Formatting extensions for Float
extension Float {
    var asLocaleCurrency:String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber.init(value: self))!
    }
}
