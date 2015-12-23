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
    let testPersistentStore  = TestPersistentStore()
    let expectationThreshold = Double(10)

    func testFollowingUserCreatesANewUser() {
        let userToFollowID      = Int64(1)
        let persitedFollowID    = NSNumber(longLong: userToFollowID)
        let screenName          = "screenName"
        let operation           = FollowUserOperation(userToFollowID: userToFollowID, screenName: screenName, persistentStore: testPersistentStore)
        let expectation = expectationWithDescription("operation completed")

        operation.queue() { error in
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(expectationThreshold) { error in
            let createdUsers: [VUser] = self.testPersistentStore.mainContext.v_findObjects(["remoteId": persitedFollowID])
            XCTAssertEqual(1, createdUsers.count)
        }
    }
}
