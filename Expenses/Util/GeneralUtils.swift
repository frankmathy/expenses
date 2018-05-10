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
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: fromDate))
    }
}
