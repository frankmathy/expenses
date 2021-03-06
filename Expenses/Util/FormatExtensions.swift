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
    
    var asLocaleDateLongTimeString:String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .medium
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

    var asLocaleWeekdayDateString:String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale.current
        let weekday = Calendar.current.component(.weekday, from: self)
        return dateFormatter.shortWeekdaySymbols[weekday-1] + " " + dateFormatter.string(from: self)
    }
    
    var asYYYYMMDDString:String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYMMdd"
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
    
    func currencyInputFormatting() -> String {
        // if first number is 0 or all numbers were deleted
        guard self != 0 else {
            return ""
        }
        return SystemConfig.sharedInstance.appCurrencySymbol + self.asLocaleCurrency.trimmingCharacters(in: .whitespaces)
    }
}

// Formatting extensions for Float
extension Double {
    var asLocaleCurrency:String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = ""
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber.init(value: self))!.trimmingCharacters(in: .whitespaces)
    }
    
    func currencyInputFormatting(currencySymbol : String) -> String {
        // if first number is 0 or all numbers were deleted
        guard self != 0 else {
            return ""
        }
        return currencySymbol + self.asLocaleCurrency
    }
    
    var asRate:String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 4
        return formatter.string(from: NSNumber.init(value: self))!.trimmingCharacters(in: .whitespaces)
    }
}

extension String {
    
    func parseCurrencyValue() -> Double {
        var amountWithPrefix = self
        let regex = try! NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive)
        amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count), withTemplate: "")
        let value = (amountWithPrefix as NSString).doubleValue
        return value / 100
    }
    
    // formatting text for currency textField
    func currencyInputFormatting(currencySymbol : String) -> String {
        return self.parseCurrencyValue().currencyInputFormatting(currencySymbol: currencySymbol)
    }
    
    func decimalInputFormatting() -> String {
        return self.parseCurrencyValue().asLocaleCurrency
    }
}
