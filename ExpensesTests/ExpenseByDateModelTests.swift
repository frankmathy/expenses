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
        model.addExpense(expense: testData.expenseTodayBakery5)
        XCTAssertEqual(model.sectionCount(), 1)
        XCTAssertEqual(model.expensesCount(inSection: 0), 1)
    }
    
    func testCreateModelWithThreeEntriesAtSameDate() {
        let model = ExpenseByDateModel()
        model.addExpense(expense: testData.expenseTodayBakery5)
        model.addExpense(expense: testData.expenseTodayAppleStore200)
        model.addExpense(expense: testData.expenseTodayBarber20)
        XCTAssertEqual(model.sectionCount(), 1)
        XCTAssertEqual(model.expensesCount(inSection: 0), 3)
    }
    
    func testCreateModelWithAllTestData() {
        let model = ExpenseByDateModel()
        model.setExpenses(expenses: testData.expenses)
        XCTAssertEqual(model.sectionCount(), 3)
        
        XCTAssertEqual(model.expensesCount(inSection: 0), 3)
        XCTAssertEqual(model.sectionDate(inSection: 0), Calendar.current.startOfDay(for: testData.today))
        XCTAssertEqual(roundTo2Dps(value: model.totalAmount(inSection: 0)), 225.0)
        
        XCTAssertEqual(model.expensesCount(inSection: 1), 2)
        XCTAssertEqual(model.sectionDate(inSection: 1), Calendar.current.startOfDay(for: testData.yesterday))
        XCTAssertEqual(roundTo2Dps(value: model.totalAmount(inSection: 1)), 145.0)

        XCTAssertEqual(model.expensesCount(inSection: 2), 1)
        XCTAssertEqual(model.sectionDate(inSection: 2), Calendar.current.startOfDay(for: testData.twoDaysAgo))
        XCTAssertEqual(roundTo2Dps(value: model.totalAmount(inSection: 2)), 30.0)
        
        XCTAssertEqual(model.grandTotal, 400.0)
    }
    
    func testReloadWorksOk() {
        let model = ExpenseByDateModel()
        model.setExpenses(expenses: testData.expenses)
        XCTAssertEqual(model.grandTotal, 400.0)
        model.setExpenses(expenses: testData.expenses)
        XCTAssertEqual(model.grandTotal, 400.0)
    }
    
    func testDeleteFromModel() {
        let model = ExpenseByDateModel()
        model.setExpenses(expenses: testData.expenses)
        XCTAssertEqual(model.sectionCount(), 3)
        
        XCTAssertEqual(model.expensesCount(inSection: 1), 2)
        model.removeExpense(inSection: 1, row: 1)
        // TODO: Fix error, somehow deletion not working
        XCTAssertEqual(model.expensesCount(inSection: 1), 1)
        XCTAssertEqual(roundTo2Dps(value: model.totalAmount(inSection: 1)), 50.0)

        XCTAssertEqual(model.expensesCount(inSection: 2), 1)
        model.removeExpense(inSection: 2, row: 0)
        XCTAssertEqual(model.sectionCount(), 2)

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
    
    func testRemoveStuff() {
        var daten = [1,2,3]
        daten.remove(at: 1)
        XCTAssertEqual(daten.count, 2)
        XCTAssertEqual(daten[1], 3)
    }
    



}
