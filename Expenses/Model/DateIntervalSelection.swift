//
//  DateIntervalSelection.swift
//  Used to calculate and store date selection
//
//  Created by Frank Mathy on 28.12.17.
//  Copyright © 2017 Frank Mathy. All rights reserved.
//

import Foundation

enum DateIntervalType {
    case Week
    case Month
    case Year
    case All
}

class DateIntervalSelection {
    var dateIntervalType : DateIntervalType
    
    var startDate : Date?
    var endDate : Date?
    
    init() {
        dateIntervalType = DateIntervalType.All
    }
    
    func setDateIntervalType(dateIntervalType: DateIntervalType) -> Bool {
        return setDateIntervalType(referenceDay: Date(), dateIntervalType: dateIntervalType)
    }
    
    func setDateIntervalType(referenceDay : Date, dateIntervalType : DateIntervalType) -> Bool {
        if self.dateIntervalType != dateIntervalType {
            self.dateIntervalType = dateIntervalType
            let calendar = Calendar.current
            if dateIntervalType == DateIntervalType.Week {
                let weekStartComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: referenceDay)
                startDate = calendar.date(from: weekStartComponents)
                endDate = calendar.date(byAdding: .day, value: 7, to: startDate!)
                endDate = calendar.date(byAdding: .second, value: -1, to: endDate!)
            } else if dateIntervalType == DateIntervalType.Month {
                let dateComponents = calendar.dateComponents([.month, .year], from: referenceDay)
                var startDateComponents = DateComponents()
                startDateComponents.day = 1
                startDateComponents.month = dateComponents.month
                startDateComponents.year = dateComponents.year
                startDateComponents.hour = 0
                startDateComponents.minute = 0
                startDateComponents.second = 0
                startDate = calendar.date(from: startDateComponents)
                endDate = calendar.date(byAdding: .month, value: 1, to: startDate!)
                endDate = calendar.date(byAdding: .second, value: -1, to: endDate!)
            } else if dateIntervalType == DateIntervalType.Year {
                let dateComponents = calendar.dateComponents([.year], from: referenceDay)
                var startDateComponents = DateComponents()
                startDateComponents.day = 1
                startDateComponents.month = 1
                startDateComponents.year = dateComponents.year
                startDateComponents.hour = 0
                startDateComponents.minute = 0
                startDateComponents.second = 0
                startDate = calendar.date(from: startDateComponents)
                endDate = calendar.date(byAdding: .year, value: 1, to: startDate!)
                endDate = calendar.date(byAdding: .second, value: -1, to: endDate!)
            }
            return true
        } else {
            return false
        }
    }
    
    func nextInterval() {
        changeInterval(toNext: true)
    }

    func previousInterval() {
        changeInterval(toNext: false)
    }
    
    private func changeInterval(toNext : Bool) {
        let calendar = Calendar.current
        if dateIntervalType == DateIntervalType.Week {
            startDate = calendar.date(byAdding: .day, value: toNext ? 7 : -7, to: startDate!)
            endDate = calendar.date(byAdding: .day, value: toNext ? 7 : -7, to: endDate!)
        } else if dateIntervalType == DateIntervalType.Month {
            startDate = calendar.date(byAdding: .month, value: toNext ? 1 : -1, to: startDate!)
            endDate = calendar.date(byAdding: .month, value: 1, to: startDate!)
            endDate = calendar.date(byAdding: .second, value: -1, to: endDate!)
        } else if dateIntervalType == DateIntervalType.Year {
            startDate = calendar.date(byAdding: .year, value: toNext ? 1 : -1, to: startDate!)
            endDate = calendar.date(byAdding: .year, value: toNext ? 1 : -1, to: endDate!)
        }
    }
    
}
