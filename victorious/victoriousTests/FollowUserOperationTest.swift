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
        let userToFollowID = 1
        let screenName = "screenName"
        let operation = FollowUserOperation(userToFollowID: userToFollowID, screenName: screenName)
    }
}