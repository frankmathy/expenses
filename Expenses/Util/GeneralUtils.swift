//
//  GeneralUtils.swift
//  Expenses
//
//  Created by Frank Mathy on 10.05.18.
//  Copyright © 2018 Frank Mathy. All rights reserved.
//

import Foundation

class GeneralUtils {
    static public func removeTimeStamp(fromDate: Date) -> Date {
        guard let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: fromDate)) else {
            fatalError("Failed to strip time from Date object")
        }
        return date
    }
}
