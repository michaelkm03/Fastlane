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
    
    func testSuccess() {
        let operation = MockFetcherOperation()
        testRequestExecutor = TestRequestExecutor(result: true)
        operation.requestExecutor = testRequestExecutor
        XCTAssert( operation.requiresAuthorization )
        
        let expectation = expectationWithDescription("MockFetcherOperation")
        operation.queue() { (results, error) in
            XCTAssertNil(error)
            XCTAssertEqual(results?.count, 2)
            XCTAssert( NSThread.isMainThread() )
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(expectationThreshold, handler: nil)
    }
    
    func testError() {
        let operation = MockFetcherOperation()
        let expectedError = NSError(domain: "Really Bad Error", code: 99, userInfo: nil)
        testRequestExecutor = TestRequestExecutor(error: expectedError)
        operation.requestExecutor = testRequestExecutor
        XCTAssert( operation.requiresAuthorization )
        
        let expectation = expectationWithDescription("MockFetcherOperation")
        operation.queue() { (results, error) in
            XCTAssertEqual(expectedError, error)
            XCTAssertNil(results)
            XCTAssert( NSThread.isMainThread() )
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(expectationThreshold, handler: nil)
    }
}
