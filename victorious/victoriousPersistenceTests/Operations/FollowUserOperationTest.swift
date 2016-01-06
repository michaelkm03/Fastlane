//
//  FollowUserOperationTest.swift
//  victorious
//
//  Created by Alex Tamoykin on 12/21/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class FollowUserOperationTest: BaseRequestOperationTests {
    let expectationThreshold: Double = 10
    var operation: FollowUserOperation!
    let userToFollowID = Int64(1)
    let currentUserID = Int64(2)
    let screenName = "screenName"

    override func setUp() {
        super.setUp()

        operation = FollowUserOperation(userToFollowID: userToFollowID, currentUserID: currentUserID, screenName: screenName)
        operation.persistentStore = testStore
        operation.trackingManager = testTrackingManager
        operation.requestExecutor = testRequestExecutor
    }

    func __testFollowingAnExistentUser() {
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
            XCTAssertEqual(true, updatedUserToFollow.isFollowedByMainUser)
            XCTAssertEqual(1, self.testTrackingManager.trackEventCalls.count)
            XCTAssertEqual(VTrackingEventUserDidFollowUser, self.testTrackingManager.trackEventCalls[0].eventName!)
            XCTAssertEqual(1, self.testRequestExecutor.executeRequestCallCount)
        }
    }

    func __testFollowingANonExistentUser() {
        let existingUsers: [VUser] = self.testStore.mainContext.v_findAllObjects()
        XCTAssertEqual(0, existingUsers.count)

        queueExpectedOperation(operation: operation)
        waitForExpectationsWithTimeout(expectationThreshold) { error in
            if let createdUsers: [VUser] = self.testStore.mainContext.v_findAllObjects() where createdUsers.count > 0 {
                XCTFail("following a non existent user created new users \(createdUsers) which it shouldn't do")
            }
            XCTAssertEqual(1, self.testTrackingManager.trackEventCalls.count)
            XCTAssertEqual(VTrackingEventUserDidFollowUser, self.testTrackingManager.trackEventCalls[0].eventName!)
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
