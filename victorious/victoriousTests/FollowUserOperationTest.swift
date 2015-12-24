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
    let testPersistentStore = TestPersistentStore()
    let expectationThreshold: Double = 10

    func testFollowingAnExistentUser() {
        let userID         = Int64(1)
        let persitedUserID = NSNumber(longLong: userID)
        let screenName     = "screenName"
        let operation      = FollowUserOperation(userToFollowID: userID, screenName: screenName, persistentStore: testPersistentStore)
        let expectation    = expectationWithDescription("operation completed")

        let createdUser: VUser = testPersistentStore.mainContext.v_createObjectAndSave { user in
            user.remoteId = persitedUserID
            user.status   = "stored"
        }

        operation.onComplete = {
            expectation.fulfill()
        }
        operation.queue()

        waitForExpectationsWithTimeout(expectationThreshold) { error in
            guard let updatedUser: VUser = self.testPersistentStore.mainContext.objectWithID(createdUser.objectID) as? VUser else {
                XCTFail("No user found after following a user")
                return
            }
            XCTAssertEqual(1, updatedUser.numberOfFollowers)
        }
    }

    override func tearDown() {
        do {
            try testPersistentStore.clear()
        } catch TestPersitentStoreError.ClearFailed(let storeURL) {
            XCTFail("Failed to clear the test persistent store at \(storeURL). Failing this test since it can cause test pollution.")
        } catch {
            XCTFail("Something went wrong while clearing persitent store")
        }
    }
}
