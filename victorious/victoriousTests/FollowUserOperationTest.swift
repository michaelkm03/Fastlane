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
    let expectationThreshold: Double = 10
    var persitedUserID: NSNumber!
    var operation: FollowUserOperation!
    var testStore: TestPersistentStore!
    let userID = Int64(1)
    let screenName = "screenName"

    override func setUp() {
        super.setUp()
        testStore = TestPersistentStore()
        persitedUserID = NSNumber(longLong: userID)
        operation = FollowUserOperation(userToFollowID: userID, screenName: screenName)
        operation.persistentStore = testStore
    }

    func testFollowingAnExistentUser() {
        let createdUser: VUser = testStore.mainContext.v_createObjectAndSave { user in
            user.remoteId = persitedUserID
            user.status = "stored"
        }

        queueExpectedOperation(operation: operation)

        waitForExpectationsWithTimeout(expectationThreshold) { error in
            guard let updatedUser: VUser = self.testStore.mainContext.objectWithID(createdUser.objectID) as? VUser else {
                XCTFail("No user found after following a user")
                return
            }
            XCTAssertEqual(1, updatedUser.numberOfFollowers)
        }
    }

    func testFollowingANonExistentUser() {
        let existingUsers: [VUser] = self.testStore.mainContext.v_findAllObjects()
        XCTAssertEqual(0, existingUsers.count)

        queueExpectedOperation(operation: operation)
        waitForExpectationsWithTimeout(expectationThreshold) { error in
            if let createdUsers: [VUser] = self.testStore.mainContext.v_findAllObjects() where createdUsers.count > 0 {
                XCTFail("following a non existent user created new users \(createdUsers) which it shouldn't do")
            }
        }
    }

    override func tearDown() {
        do {
            try testStore.clear()
        } catch TestPersitentStoreError.ClearFailed(let storeURL) {
            XCTFail("Failed to clear the test persistent store at \(storeURL). Failing this test since it can cause test pollution.")
        } catch {
            XCTFail("Something went wrong while clearing persitent store")
        }
    }

    private func queueExpectedOperation(operation operation: FollowUserOperation) -> XCTestExpectation {
        let expectation = expectationWithDescription("operation completed")
        operation.queue() { error in
            expectation.fulfill()
        }
        return expectation
    }
}
