//
//  FollowUserOperationTest.swift
//  victorious
//
//  Created by Alex Tamoykin on 12/21/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class FollowUserOperationTest: XCTestCase {
    func testFollowingUser() {
        let userToFollowID      = Int64(1)
        let screenName          = "screenName"
        let testPersistentStore = TestPersistentStore()
        let operation           = FollowUserOperation(userToFollowID: userToFollowID, screenName: screenName, persistentStore: testPersistentStore)
    }
}