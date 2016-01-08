//
//  RequestPasswordResetOperationTests.swift
//  victorious
//
//  Created by Tian Lan on 1/7/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class RequestPasswordResetOperationTests: XCTestCase {

    let mockDeviceToken = "MockDeviceToken"
    
    func testMain() {
        let operation = RequestPasswordResetOperation(email: "mockEmail")
        let testExecutor = TestRequestExecutor()
        
        operation.requestExecutor = testExecutor
        operation.main()

        XCTAssertEqual(1, testExecutor.executeRequestCallCount)
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
