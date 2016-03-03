//
//  PasswordValidateResetTokenOperationTests.swift
//  victorious
//
//  Created by Tian Lan on 1/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class PasswordValidateResetTokenOperationTests: BaseFetcherOperationTestCase {
    
    func testMain() {
        let operation = PasswordValidateResetTokenOperation(userToken: "usertoken", deviceToken: "devicetoken")
        testRequestExecutor = TestRequestExecutor()
        operation.requestExecutor = testRequestExecutor
        
        let expectation = expectationWithDescription("PasswordValidateResetTokenOperation")
        operation.queue() { (results, error) in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(expectationThreshold) { error in
            XCTAssertEqual(1, self.testRequestExecutor.executeRequestCallCount)
        }
    }
}
