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
    let userToUnfollowID = Int64(1)
    let currentUserID = Int64(2)
    let screenName = "screenName"
    let operationHelper = RequestOperationTestHelper()

    override func setUp() {
        super.setUp()
        testStore = TestPersistentStore()
        operation = UnfollowUserOperation(userToUnfollowID: userToUnfollowID, currentUserID: currentUserID, screenName: screenName)
    }

    func testUnfollowingAnExistingUser() {
    }

    override func tearDown() {
        super.tearDown()
    }
}
