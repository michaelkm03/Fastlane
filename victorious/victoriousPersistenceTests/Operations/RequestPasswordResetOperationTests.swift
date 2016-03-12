//
//  PasswordRequestResetOperationTests.swift
//  victorious
//
//  Created by Tian Lan on 1/7/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class PasswordRequestResetOperationTests: BaseFetcherOperationTestCase {

    let mockDeviceToken = "MockDeviceToken"
    
    func test() {
        let operation = PasswordRequestResetOperation(email: "mockEmail")
        testRequestExecutor = TestRequestExecutor(result: mockDeviceToken)
        operation.requestExecutor = testRequestExecutor
        
        let expectation = expectationWithDescription("PasswordRequestResetOperation")
        operation.queue() { results, error, cancelled in
            XCTAssertEqual(1, self.testRequestExecutor.executeRequestCallCount)
            XCTAssertEqual(operation.deviceToken, self.mockDeviceToken)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(expectationThreshold, handler:nil)
    }
}
