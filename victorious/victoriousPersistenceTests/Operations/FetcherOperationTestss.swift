//
//  FetcherOperationTests.swift
//  victorious
//
//  Created by Patrick Lynch on 11/19/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class FetcherOperationTests: BaseFetcherOperationTestCase {
    
    func testOnCompletion() {
        let requestOperation = MockFetcherOperation(request: MockRequest())
        requestOperation.requestExecutor = TestRequestExecutor()
        
        let expectation = expectationWithDescription("MockFetcherOperation")
        requestOperation.queueOn(requestOperation.v_defaultQueue) { (results, error) in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(expectationThreshold, handler: nil)
    }
    
    func testOnError() {
        let errorOperation = MockFetcherOperation(request: MockRequest())
        let expectedError = NSError(domain:"test", code:-1, userInfo:nil)
        errorOperation.requestExecutor = TestRequestExecutor(error: expectedError)
        
        let expectation = expectationWithDescription("MockErrorFetcherOperation")
        errorOperation.queue() { (results, error) in
            XCTAssertEqual(expectedError, error)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(expectationThreshold, handler: nil)
    }
}
