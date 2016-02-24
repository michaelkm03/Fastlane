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
    
    func testMain() {
        let operation = RequestPasswordResetOperation(email: "mockEmail")
        operation.requestExecutor = testRequestExecutor
        operation.main()

        XCTAssertEqual(1, testRequestExecutor.executeRequestCallCount)
    }

    func testOnComplete() {
        var completionBlockExecuted = false
        let operation = RequestPasswordResetOperation(email: "mockEmail")
        operation.onComplete(mockDeviceToken) {
            completionBlockExecuted = true
        }

        XCTAssertTrue(completionBlockExecuted)
        XCTAssertEqual(operation.deviceToken, mockDeviceToken)
    }
}
