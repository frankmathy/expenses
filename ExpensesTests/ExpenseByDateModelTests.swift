//
//  ExpenseByDateModelTests.swift
//  ExpensesTests
//
//  Created by Frank Mathy on 22.12.17.
//  Copyright © 2017 Frank Mathy. All rights reserved.
//

import XCTest

class ExpenseByDateModelTests: XCTestCase {
    
    let testData = TestData()
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreateEmtpyModel() {
        let model = ExpenseByDateModel()
        XCTAssertEqual(model.sectionCount(), 0)
    }
    
    func testCreateModelWithOneEntry() {
        let model = ExpenseByDateModel()
        model.addExpense(expense: testData.expenseTodayBakery)
        XCTAssertEqual(model.sectionCount(), 1)
        XCTAssertEqual(model.expensesCount(inSection: 0), 1)
    }
    
    func testCreateModelWithThreeEntriesAtSameDate() {
        let model = ExpenseByDateModel()
        model.addExpense(expense: testData.expenseTodayBakery)
        model.addExpense(expense: testData.expenseTodayAppleStore)
        model.addExpense(expense: testData.expenseTodayBarber)
        XCTAssertEqual(model.sectionCount(), 1)
        XCTAssertEqual(model.expensesCount(inSection: 0), 3)
    }
    
    func testCreateModelWithAllTestData() {
        let model = ExpenseByDateModel()
        model.setExpenses(expenses: testData.expenses)
        XCTAssertEqual(model.sectionCount(), 3)
        
        XCTAssertEqual(model.expensesCount(inSection: 0), 3)
        XCTAssertEqual(model.sectionDate(inSection: 0), Calendar.current.startOfDay(for: testData.today))
        XCTAssertEqual(roundTo2Dps(value: model.totalAmount(inSection: 0)), 37.9)
        
        XCTAssertEqual(model.expensesCount(inSection: 1), 2)
        XCTAssertEqual(model.sectionDate(inSection: 1), Calendar.current.startOfDay(for: testData.yesterday))
        XCTAssertEqual(roundTo2Dps(value: model.totalAmount(inSection: 1)), 104.94)

        XCTAssertEqual(model.expensesCount(inSection: 2), 1)
        XCTAssertEqual(model.sectionDate(inSection: 2), Calendar.current.startOfDay(for: testData.twoDaysAgo))
        XCTAssertEqual(roundTo2Dps(value: model.totalAmount(inSection: 2)), 28.0)
    }
    
    func testClearModelRemovesAllEntries() {
        let model = ExpenseByDateModel()
        model.setExpenses(expenses: testData.expenses)
        model.removeAll()
        XCTAssertEqual(model.sectionCount(), 0)
    }
    
    func roundTo2Dps(value : Float) -> Float {
        return ((value*100.0).rounded()) / 100.0
    }
    


}
