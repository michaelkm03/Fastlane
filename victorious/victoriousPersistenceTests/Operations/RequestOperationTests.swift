//
//  RequestOperationTests.swift
//  victorious
//
//  Created by Patrick Lynch on 11/19/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
@testable import victorious
import Nocilla

class RequestOperationTests: XCTestCase {

    override func setUp() {
        super.setUp()
        LSNocilla.sharedInstance().start()
    }
    
    override func tearDown() {
        super.tearDown()
        LSNocilla.sharedInstance().clearStubs()
        LSNocilla.sharedInstance().stop()
    }
    
    func testOnCompletion() {
        let expectation = self.expectationWithDescription("testValid")
        let requestOperation = MockRequestOperation(request: MockRequest())
        let url = requestOperation.validRequest.urlRequest.URL?.absoluteString
        
        stubRequest("GET", url)
        
        requestOperation.queueOn(requestOperation.defaultQueue) { error in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testOnError() {
        let expectation = self.expectationWithDescription("testError")
        let errorOperation = MockErrorRequestOperation(request: MockErrorRequest())
        let url = errorOperation.errorRequest.urlRequest.URL?.absoluteString
        
        stubRequest("GET", url)
        
        errorOperation.queueOn(errorOperation.defaultQueue) { error in
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2, handler: nil)
    }
}
