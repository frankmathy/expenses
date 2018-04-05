//
//  DateIntervalSelectionTests.swift
//  ExpensesTests
//
//  Created by Frank Mathy on 28.12.17.
//  Copyright © 2017 Frank Mathy. All rights reserved.
//

import XCTest

class DateIntervalSelectionTests: XCTestCase {
    
    var dateFormatter = DateFormatter()
    
    override func setUp() {
        super.setUp()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        dateFormatter.locale = Locale.current
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    /* TODO FIX TESTS
    func testSetDateIntervalWeek() {
        let selection = DateIntervalSelection()
        let referenceDate = dateFormatter.date(from: "15.08.2017 12:34:15")
        selection.setDateIntervalType(referenceDay: referenceDate!, dateIntervalType: DateIntervalType.Week)
        XCTAssertNotNil(selection.startDate)
        XCTAssertEqual(dateFormatter.string(from: selection.startDate!), "14.08.2017 00:00:00")
        XCTAssertNotNil(selection.endDate)
        XCTAssertEqual(dateFormatter.string(from: selection.endDate!), "20.08.2017 23:59:59")
        selection.nextInterval()
        XCTAssertEqual(dateFormatter.string(from: selection.startDate!), "21.08.2017 00:00:00")
        XCTAssertEqual(dateFormatter.string(from: selection.endDate!), "27.08.2017 23:59:59")
        selection.previousInterval()
        selection.previousInterval()
        XCTAssertEqual(dateFormatter.string(from: selection.startDate!), "07.08.2017 00:00:00")
        XCTAssertEqual(dateFormatter.string(from: selection.endDate!), "13.08.2017 23:59:59")
    }
    
    func testSetDateIntervalMonth() {
        let selection = DateIntervalSelection()
        let referenceDate = dateFormatter.date(from: "15.08.2017 12:34:15")
        selection.setDateIntervalType(referenceDay: referenceDate!, dateIntervalType: DateIntervalType.Month)
        XCTAssertNotNil(selection.startDate)
        XCTAssertEqual(dateFormatter.string(from: selection.startDate!), "01.08.2017 00:00:00")
        XCTAssertNotNil(selection.endDate)
        XCTAssertEqual(dateFormatter.string(from: selection.endDate!), "31.08.2017 23:59:59")
        selection.nextInterval()
        XCTAssertEqual(dateFormatter.string(from: selection.startDate!), "01.09.2017 00:00:00")
        XCTAssertEqual(dateFormatter.string(from: selection.endDate!), "30.09.2017 23:59:59")
        selection.previousInterval()
        selection.previousInterval()
        XCTAssertEqual(dateFormatter.string(from: selection.startDate!), "01.07.2017 00:00:00")
        XCTAssertEqual(dateFormatter.string(from: selection.endDate!), "31.07.2017 23:59:59")
    }
    
    func testSetDateIntervalYear() {
        let selection = DateIntervalSelection()
        let referenceDate = dateFormatter.date(from: "15.08.2017 12:34:15")
        selection.setDateIntervalType(referenceDay: referenceDate!, dateIntervalType: DateIntervalType.Year)
        XCTAssertNotNil(selection.startDate)
        XCTAssertEqual(dateFormatter.string(from: selection.startDate!), "01.01.2017 00:00:00")
        XCTAssertNotNil(selection.endDate)
        XCTAssertEqual(dateFormatter.string(from: selection.endDate!), "31.12.2017 23:59:59")
        selection.nextInterval()
        XCTAssertEqual(dateFormatter.string(from: selection.startDate!), "01.01.2018 00:00:00")
        XCTAssertEqual(dateFormatter.string(from: selection.endDate!), "31.12.2018 23:59:59")
        selection.previousInterval()
        selection.previousInterval()
        XCTAssertEqual(dateFormatter.string(from: selection.startDate!), "01.01.2016 00:00:00")
        XCTAssertEqual(dateFormatter.string(from: selection.endDate!), "31.12.2016 23:59:59")
    }*/

}
