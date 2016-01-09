//
//  MainRequestExecutorTests.swift
//  victorious
//
//  Created by Tian Lan on 1/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class MainRequestExecutorTests: XCTestCase {
    
    func testOnComplete() {
        let expectation = self.expectationWithDescription("testBasic")
        let requestOperation = MockRequestOperation(request: MockRequest())
        
        requestOperation.queueOn(requestOperation.defaultQueue) { error in
            expectation.fulfill()
            XCTAssertNil(error)
        }
        
        waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testOnError() {
        let expectation = self.expectationWithDescription("testError")
        let errorOperation = MockErrorRequestOperation(request: MockErrorRequest())
        
        errorOperation.queueOn(errorOperation.defaultQueue) { error in
            expectation.fulfill()
            XCTAssertNotNil(error)
        }

        waitForExpectationsWithTimeout(2, handler: nil)
    }
}
