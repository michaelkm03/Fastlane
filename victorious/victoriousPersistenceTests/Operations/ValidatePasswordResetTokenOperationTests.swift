//
//  ValidatePasswordResetTokenOperationTests.swift
//  victorious
//
//  Created by Tian Lan on 1/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class ValidatePasswordResetTokenOperationTests: BaseFetcherOperationTestCase {
    
    func testMain() {
        let operation = ValidatePasswordResetTokenOperation(userToken: "usertoken", deviceToken: "devicetoken")
        testRequestExecutor = TestRequestExecutor()
        operation.requestExecutor = testRequestExecutor
        
        let expectation = expectationWithDescription("ValidatePasswordResetTokenOperation")
        operation.queue() { (results, error) in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(expectationThreshold) { error in
            XCTAssertEqual(1, self.testRequestExecutor.executeRequestCallCount)
        }
    }
}
