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

    func testFollowingAnExistentUser() {
        let userID         = Int64(1)
        let persitedUserID = NSNumber(longLong: userID)
        let screenName     = "screenName"
        let operation      = FollowUserOperation(userToFollowID: userID, screenName: screenName, persistentStore: testPersistentStore)
        let expectation    = expectationWithDescription("operation completed")

        testPersistentStore.mainContext.v_createObjectAndSave { user in
            user.remoteId = persitedUserID
            user.status   = "stored"
        } as VUser

        operation.onComplete = {
            expectation.fulfill()
        }
        operation.queue()

        waitForExpectationsWithTimeout(expectationThreshold) { error in
            let createdUsers: [VUser] = self.testPersistentStore.mainContext.v_findObjects(["remoteId": persitedUserID])
            let userCreated = createdUsers[0]
            XCTAssertEqual(1, createdUsers.count)
            XCTAssertEqual(1, userCreated.numberOfFollowers)
        }
    }

    override func tearDown() {
        testPersistentStore.clear()
    }
}
