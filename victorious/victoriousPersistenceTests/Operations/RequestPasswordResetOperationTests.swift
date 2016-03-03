//
//  RequestPasswordResetOperationTests.swift
//  victorious
//
//  Created by Tian Lan on 1/7/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class RequestPasswordResetOperationTests: BaseFetcherOperationTestCase {

    let mockDeviceToken = "MockDeviceToken"
    
    func test() {
        let operation = RequestPasswordResetOperation(email: "mockEmail")
        testRequestExecutor = TestRequestExecutor(result: mockDeviceToken)
        operation.requestExecutor = testRequestExecutor
        operation.persistentStore = testStore
        
        let expectation = expectationWithDescription("RequestPasswordResetOperation")
        operation.queue() { (results, error) in
            XCTAssertEqual(1, self.testRequestExecutor.executeRequestCallCount)
            XCTAssertEqual(operation.deviceToken, self.mockDeviceToken)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(expectationThreshold, handler:nil)
    }
}
