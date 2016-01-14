//
//  RegisterPushNotificationOperationTests.swift
//  victorious
//
//  Created by Tian Lan on 1/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class RegisterPushNotificationOperationTests: XCTestCase {
    
    func testMain() {
        let operation = RegisterPushNotificationOperation(pushNotificationID: "mockPushNotificationID")
        let testExecutor = TestRequestExecutor()
        
        operation.requestExecutor = testExecutor
        operation.main()
        
        XCTAssertEqual(1, testExecutor.executeRequestCallCount)
    }
}
