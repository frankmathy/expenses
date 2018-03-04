//
//  ExchangeRateServiceTest.swift
//  ExpensesTests
//
//  Created by Frank Mathy on 04.03.18.
//  Copyright © 2018 Frank Mathy. All rights reserved.
//

import XCTest

class ExchangeRateServiceTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testGetRate() {
        let dispatchGroup = DispatchGroup()
        let service = ExchangeRateService()
        dispatchGroup.enter()
        service.getRate(baseCcy: "EUR", termsCcy: "USD") { (rate, errorMessage) in
            XCTAssertNil(errorMessage)
            XCTAssertNotNil(rate)
            print("Rate: \(rate)")
            dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: .main) {
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
