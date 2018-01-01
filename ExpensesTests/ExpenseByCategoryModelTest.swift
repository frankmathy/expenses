//
//  ExpenseByCategoryModelTest.swift
//  ExpensesTests
//
//  Created by Frank Mathy on 01.01.18.
//  Copyright © 2018 Frank Mathy. All rights reserved.
//

import XCTest

class ExpenseByCategoryModelTest: XCTestCase {
    
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
        let model = ExpenseByCategoryModel()
        XCTAssertEqual(model.sectionCount(), 0)
    }
    
    func testCreateModelWithOneEntry() {
        let model = ExpenseByCategoryModel()
        model.addExpense(expense: testData.expenseTodayBakery5)
        XCTAssertEqual(model.sectionCount(), 1)
        XCTAssertEqual(model.expensesCount(inSection: 0), 1)
    }
    
    func testCreateModelWithThreeEntriesAtSameDate() {
        let model = ExpenseByCategoryModel()
        model.addExpense(expense: testData.expenseTodayBakery5)
        model.addExpense(expense: testData.expenseTodayAppleStore200)
        model.addExpense(expense: testData.expenseTodayBarber20)
        XCTAssertEqual(model.sectionCount(), 3)
        XCTAssertEqual(model.expensesCount(inSection: 0), 1)
    }
    
    func testCreateModelWithAllTestData() {
        let model = ExpenseByCategoryModel()
        model.setExpenses(expenses: testData.expenses)
        XCTAssertEqual(model.sectionCount(), 5)
        
        XCTAssertEqual(model.expensesCount(inSection: 0), 1)
        XCTAssertEqual(model.sectionCategoryName(inSection: 0), "Bäcker")
        XCTAssertEqual(roundTo2Dps(value: model.totalAmount(inSection: 0)), 5.0)
        
        XCTAssertEqual(model.expensesCount(inSection: 1), 1)
        XCTAssertEqual(model.sectionCategoryName(inSection: 1), "Freizeit/Hobby")
        XCTAssertEqual(roundTo2Dps(value: model.totalAmount(inSection: 1)), 200.0)
        
        XCTAssertEqual(model.expensesCount(inSection: 2), 2)
        XCTAssertEqual(model.sectionCategoryName(inSection: 2), "Friseur")
        XCTAssertEqual(roundTo2Dps(value: model.totalAmount(inSection: 2)), 50.0)
        
        XCTAssertEqual(model.grandTotal, 400.0)
    }
    
    func testReloadWorksOk() {
        let model = ExpenseByCategoryModel()
        model.setExpenses(expenses: testData.expenses)
        XCTAssertEqual(model.grandTotal, 400.0)
        model.setExpenses(expenses: testData.expenses)
        XCTAssertEqual(model.grandTotal, 400.0)
    }
    
    func testDeleteFromModel() {
        let model = ExpenseByCategoryModel()
        model.setExpenses(expenses: testData.expenses)
        XCTAssertEqual(model.sectionCount(), 5)
        
        XCTAssertEqual(model.expensesCount(inSection: 2), 2)
        model.removeExpense(inSection: 2, row: 0)
        XCTAssertEqual(model.expensesCount(inSection: 2), 1)
        XCTAssertEqual(roundTo2Dps(value: model.totalAmount(inSection: 2)), 30.0)
        
        XCTAssertEqual(model.expensesCount(inSection: 2), 1)
        model.removeExpense(inSection: 2, row: 0)
        XCTAssertEqual(model.sectionCount(), 4)
    }
    
    func testClearModelRemovesAllEntries() {
        let model = ExpenseByCategoryModel()
        model.setExpenses(expenses: testData.expenses)
        model.removeAll()
        XCTAssertEqual(model.sectionCount(), 0)
    }
    
    func roundTo2Dps(value : Float) -> Float {
        return ((value*100.0).rounded()) / 100.0
    }
    
}
