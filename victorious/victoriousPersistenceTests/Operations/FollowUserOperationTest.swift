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
    let userToFollowID = 1
    let currentUserID = 2
    let screenName = "screenName"

    override func setUp() {
        super.setUp()

        operation = FollowUserOperation(userToFollowID: userToFollowID, currentUserID: currentUserID, screenName: screenName)
        operation.persistentStore = testStore
        operation.eventTracker = testTrackingManager
        operation.requestExecutor = testRequestExecutor
        VCurrentUser.persistentStore = testStore
    }

    func testFollowingAnExistentUser() {
        
        let createdCurrentUser = createUser(remoteId: currentUserID)
        createdCurrentUser.setAsCurrentUser()
        
        let createdUserToFollow = createUser(remoteId: userToFollowID)

        queueExpectedOperation(operation: operation)

        waitForExpectationsWithTimeout(expectationThreshold) { error in
            guard let updatedUserToFollow = self.testStore.mainContext.objectWithID(createdUserToFollow.objectID) as? VUser else {
                XCTFail("No user to follow found after following a user")
                return
            }
            guard let currentUser = VCurrentUser.user() else {
                XCTFail("No current user found after following a user")
                return
            }
            
            XCTAssertEqual(1, updatedUserToFollow.numberOfFollowers)
            XCTAssertEqual(1, updatedUserToFollow.followers.count)
            if updatedUserToFollow.followers.count == 1, let user = Array(updatedUserToFollow.followers)[0] as? VUser {
                XCTAssertEqual( user, updatedUserToFollow )
            }
            
            XCTAssertEqual(1, currentUser.numberOfFollowing)
            XCTAssertEqual(1, currentUser.following.count)
            if currentUser.following.count == 1, let user = Array(currentUser.following)[0] as? VUser {
                XCTAssertEqual(user, updatedUserToFollow)
            }
            
            XCTAssertEqual(true, updatedUserToFollow.isFollowedByMainUser)
            
            XCTAssertEqual(1, self.testTrackingManager.trackEventCalls.count)
            if self.testTrackingManager.trackEventCalls.count >= 1 {
                XCTAssertEqual(VTrackingEventUserDidFollowUser, self.testTrackingManager.trackEventCalls[0].eventName!)
            }
            XCTAssertEqual(1, self.testRequestExecutor.executeRequestCallCount)
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
            XCTAssertEqual(1, self.testTrackingManager.trackEventCalls.count)
            if self.testTrackingManager.trackEventCalls.count >= 1 {
                XCTAssertEqual(VTrackingEventUserDidFollowUser, self.testTrackingManager.trackEventCalls[0].eventName!)
            }
            XCTAssertEqual(0, self.testRequestExecutor.executeRequestCallCount)
        }
    }

    private func createUser(remoteId remoteId: Int) -> VUser {
        return testStore.mainContext.v_createObjectAndSave { user in
            user.remoteId = remoteId
            user.status = "stored"
        } as VUser
    }
}
