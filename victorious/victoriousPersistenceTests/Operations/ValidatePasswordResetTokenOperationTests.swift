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
        operation.requestExecutor = testRequestExecutor

        operation.main()
        
        XCTAssertEqual(1, testRequestExecutor.executeRequestCallCount)
    }
}
