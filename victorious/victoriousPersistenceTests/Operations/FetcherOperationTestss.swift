//
//  FetcherOperationTests.swift
//  victorious
//
//  Created by Patrick Lynch on 11/19/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
@testable import victorious
import Nocilla

class FetcherOperationTests: XCTestCase {

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
        let expectation = self.expectationWithDescription("testOnCompletion")
        let requestOperation = MockFetcherOperation(request: MockRequest())
        let url = requestOperation.request.urlRequest.URL?.absoluteString
        
        stubRequest("GET", url)
        
        requestOperation.queueOn(requestOperation.defaultQueue) { (results, error) in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testOnError() {
        let expectation = self.expectationWithDescription("testOnError")
        let errorOperation = MockErrorFetcherOperation(request: MockErrorRequest())
        let url = errorOperation.request.urlRequest.URL?.absoluteString
        
        stubRequest("GET", url)
        
        errorOperation.queueOn(errorOperation.defaultQueue) { (results, error) in
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2, handler: nil)
    }
}
