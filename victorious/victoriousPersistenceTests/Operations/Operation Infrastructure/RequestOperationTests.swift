//
//  RequestOperationTests.swift
//  victorious
//
//  Created by Jarod Long on 9/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class RequestOperationTests: XCTestCase {
    func testSuccessfulRequest() {
        let operation = RequestOperation(request: MockRequest())
        operation.requestExecutor = TestRequestExecutor(result: true)
        
        let expectation = expectationWithDescription("Successful RequestOperation")
        
        operation.execute { result in
            expectation.fulfill()
            XCTAssert(result.output == true)
            XCTAssertNil(result.error)
        }
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func testUnsuccessfulRequest() {
        let operation = RequestOperation(request: MockRequest())
        operation.requestExecutor = TestRequestExecutor(error: NSError(domain: "RequestOperationTests", code: -1, userInfo: [:]))
        
        let expectation = expectationWithDescription("Unsuccessful RequestOperation")
        
        operation.execute { result in
            expectation.fulfill()
            XCTAssertNil(result.output)
            XCTAssertNotNil(result.error)
        }
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
}
