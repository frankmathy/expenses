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
        formatter.currencySymbol = ""
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber.init(value: self))!
    }
}

extension String {
    
    func parseCurrencyValue() -> Float {
        var amountWithPrefix = self
        let regex = try! NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive)
        amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count), withTemplate: "")
        let value = (amountWithPrefix as NSString).floatValue
        return value / 100
    }
    
    // formatting text for currency textField
    func currencyInputFormatting() -> String {
        var value = self.parseCurrencyValue()
        
        // if first number is 0 or all numbers were deleted
        guard value != 0 as Float else {
            return ""
        }
        
        return Locale.current.currencySymbol! + value.asLocaleCurrency.trimmingCharacters(in: .whitespaces)
    }
}
