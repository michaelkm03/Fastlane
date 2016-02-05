//
//  LoginOperationTests.swift
//  victorious
//
//  Created by Alex Tamoykin on 2/5/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class LoginOperationTests: BaseRequestOperationTestCase {
    var operation: LoginOperation!

    override func setUp() {
        super.setUp()
        operation = LoginOperation(email: "dude@example.com", password: "password")
        operation.requestExecutor = testRequestExecutor
    }

    func testMain() {
        XCTAssertEqual(0, testRequestExecutor.executeRequestCallCount)
        operation.main()
        XCTAssertEqual(1, testRequestExecutor.executeRequestCallCount)
    }
}
