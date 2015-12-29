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
    var operation: FollowUserOperation!
    var testStore: TestPersistentStore!
    let userToFollowID = Int64(1)
    let currentUserID = Int64(2)
    let screenName = "screenName"

    override func setUp() {
        super.setUp()
        testStore = TestPersistentStore()
        operation = FollowUserOperation(userToFollowID: userToFollowID, currentUserID: currentUserID, screenName: screenName)
        operation.persistentStore = testStore
    }

    func testFollowingAnExistentUser() {
        let createdCurrentUser = createUser(remoteId: currentUserID)
        let createdUserToFollow = createUser(remoteId: userToFollowID)
        queueExpectedOperation(operation: operation)

        waitForExpectationsWithTimeout(expectationThreshold) { error in
            guard let updatedUserToFollow = self.testStore.mainContext.objectWithID(createdUserToFollow.objectID) as? VUser else {
                XCTFail("No user to follow found after following a user")
                return
            }

            guard let updatedCurrentUser = self.testStore.mainContext.objectWithID(createdCurrentUser.objectID) as? VUser else {
                XCTFail("No current user found after following a user")
                return
            }
            XCTAssertEqual(1, updatedUserToFollow.numberOfFollowers)
            XCTAssertEqual(1, updatedCurrentUser.numberOfFollowing)
            XCTAssertEqual(1, updatedCurrentUser.following.count)
            XCTAssert(updatedCurrentUser.following.contains(updatedUserToFollow))
            XCTAssertEqual(1, updatedUserToFollow.isFollowedByMainUser)
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
            try testStore.deletePersistentStore()
        } catch PersistentStoreError.DeleteFailed(let storeURL, let error) {
            XCTFail("Failed to clear the test persistent store at \(storeURL) because of \(error)." +
                "Failing this test since it can cause test pollution.")
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

    private func createUser(remoteId remoteId: Int64) -> VUser {
        return testStore.mainContext.v_createObjectAndSave { user in
            user.remoteId = NSNumber(longLong: remoteId)
            user.status = "stored"
        } as VUser
    }
}
