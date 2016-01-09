//
//  MainRequestExecutorTests.swift
//  victorious
//
//  Created by Tian Lan on 1/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious
import Nocilla

class MainRequestExecutorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        LSNocilla.sharedInstance().start()
        stubRequest("GET", "http://www.example.com")
    }

    override func tearDown() {
        super.tearDown()
        
        LSNocilla.sharedInstance().clearStubs()
        LSNocilla.sharedInstance().stop()
    }
    
    func testValidRequestExecution() {
        let expectation = self.expectationWithDescription("testValid")
        let requestOperation = MockRequestOperation(request: MockRequest())
        let url = requestOperation.validRequest.urlRequest.URL?.absoluteString

        stubRequest("GET", url)
        
        requestOperation.queueOn(requestOperation.defaultQueue) { error in
            expectation.fulfill()
            XCTAssertNil(error)
        }
        
        waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testErrorRequestExecution() {
        let expectation = self.expectationWithDescription("testError")
        let errorOperation = MockErrorRequestOperation(request: MockErrorRequest())
        let url = errorOperation.errorRequest.urlRequest.URL?.absoluteString
        
        stubRequest("GET", url)

        errorOperation.queueOn(errorOperation.defaultQueue) { error in
            expectation.fulfill()
            XCTAssertNotNil(error)
        }

        waitForExpectationsWithTimeout(2, handler: nil)
    }
}
