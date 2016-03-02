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
    
    func testCancel() {
        let operation = MockFetcherOperation()
        testRequestExecutor = TestRequestExecutor(result: true)
        operation.requestExecutor = testRequestExecutor
        XCTAssert( operation.requiresAuthorization, "Default value should be true" )
        
        let expectation = expectationWithDescription("MockFetcherOperation")
        operation.cancel()
        operation.queue() { (results, error) in
            XCTFail("Completion block should not be called if cancelled.")
        }
        
        dispatch_after(expectationThreshold) {
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(expectationThreshold) { error in
            XCTAssertEqual(self.testRequestExecutor.executeRequestCallCount, 0)
        }
    }
    
    func testSuccess() {
        let operation = MockFetcherOperation()
        testRequestExecutor = TestRequestExecutor(result: true)
        operation.requestExecutor = testRequestExecutor
        XCTAssert( operation.requiresAuthorization, "Default value should be true" )
        
        let expectation = expectationWithDescription("MockFetcherOperation")
        operation.queue() { (results, error) in
            XCTAssertNil(error)
            XCTAssertEqual(results?.count, 2)
            XCTAssertEqual(self.testRequestExecutor.executeRequestCallCount, 1)
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
        XCTAssert( operation.requiresAuthorization, "Default value should be true" )
        
        let expectation = expectationWithDescription("MockFetcherOperation")
        operation.queue() { (results, error) in
            XCTAssertEqual(expectedError, error)
            XCTAssertNil(results)
            XCTAssert( NSThread.isMainThread() )
            XCTAssertEqual(self.testRequestExecutor.executeRequestCallCount, 1)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(expectationThreshold, handler: nil)
    }
}
