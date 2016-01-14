//
//  PasswordResetOperationTests.swift
//  victorious
//
//  Created by Tian Lan on 1/7/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class PasswordResetOperationTests: BaseRequestOperationTestCase {
    
    func testMain() {
        let operation = PasswordResetOperation(newPassword: "password", userToken: "usertoken", deviceToken: "devicetoken")
        operation.requestExecutor = testRequestExecutor
        operation.main()
        
        XCTAssertEqual(1, testRequestExecutor.executeRequestCallCount)
    }
}
