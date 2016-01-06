//
//  UnfollowUserOperationTests.swift
//  victorious
//
//  Created by Alex Tamoykin on 1/2/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class UnfollowUserOperationTests: XCTestCase {
    var operation: UnfollowUserOperation!
    var testStore: TestPersistentStore!
    let userID = 1
    let currentUserID = 2
    let screenName = "screenName"
    let operationHelper = RequestOperationTestHelper()

    override func setUp() {
        super.setUp()
        testStore = TestPersistentStore()
        operation = UnfollowUserOperation(userID: userID, screenName: screenName)
    }

    func testUnfollowingAnExistingUser() {
    }

    override func tearDown() {
        super.tearDown()
    }
}
