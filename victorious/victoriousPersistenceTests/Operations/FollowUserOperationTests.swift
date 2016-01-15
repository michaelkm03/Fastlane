//
//  FollowUserOperationTests.swift
//  victorious
//
//  Created by Alex Tamoykin on 12/21/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
@testable import victorious
@testable import VictoriousIOSSDK

class FollowUserOperationTests: BaseRequestOperationTestCase {
    var operation: FollowUserOperation!
    let userID: Int = 1
    let currentUserID: Int = 2
    let screenName = "screenName"

    override func setUp() {
        super.setUp()
        self.continueAfterFailure = false
        operation = FollowUserOperation(userID: userID, screenName: screenName)
        operation.eventTracker = testTrackingManager
        operation.requestExecutor = testRequestExecutor
    }

    func testFollowingAnExistentUser() {
        let createdCurrentUser = persistentStoreHelper.createUser(remoteId: currentUserID)
        createdCurrentUser.setAsCurrentUser()
        
        let createdUserToFollow = persistentStoreHelper.createUser(remoteId: userID)
        operation.main()
        
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
        if updatedUserToFollow.followers.count == 1, let followedUsers = Array(updatedUserToFollow.followers) as? [VFollowedUser] {
            XCTAssertEqual(1, followedUsers.count)
            XCTAssertEqual( updatedUserToFollow, followedUsers[0].objectUser )
            XCTAssertEqual( currentUser, followedUsers[0].subjectUser )
        } else {
            XCTFail("Can't find a follow relationship after following a user")
        }
        
        XCTAssertEqual(1, currentUser.numberOfFollowing)
        XCTAssertEqual(1, currentUser.following.count)
        if currentUser.following.count == 1, let followedUsers = Array(currentUser.following) as? [VFollowedUser] {
            XCTAssertEqual(1, followedUsers.count)
            XCTAssertEqual(updatedUserToFollow, followedUsers[0].objectUser)
            XCTAssertEqual(currentUser, followedUsers[0].subjectUser)
        } else {
            XCTFail("Can't find a follow relationship after following a user")
        }
        
        XCTAssert( updatedUserToFollow.isFollowedByMainUser.boolValue )
        
        XCTAssertEqual(1, self.testTrackingManager.trackEventCalls.count)
        if self.testTrackingManager.trackEventCalls.count >= 1 {
            XCTAssertEqual(VTrackingEventUserDidFollowUser, self.testTrackingManager.trackEventCalls[0].eventName!)
        }
    }

    func testFollowingANonExistentUser() {
        let existingUsers: [VUser] = self.testStore.mainContext.v_findAllObjects()
        XCTAssertEqual(0, existingUsers.count)
        XCTAssertEqual(0, self.testRequestExecutor.executeRequestCallCount)

        operation.main()

        if let createdUsers: [VUser] = self.testStore.mainContext.v_findAllObjects() where createdUsers.count > 0 {
            XCTFail("following a non existent user created new users \(createdUsers) which it shouldn't do")
        }

        XCTAssertEqual(1, self.testRequestExecutor.executeRequestCallCount)
        XCTAssertEqual(1, self.testTrackingManager.trackEventCalls.count)
        if self.testTrackingManager.trackEventCalls.count >= 1 {
            XCTAssertEqual(VTrackingEventUserDidFollowUser, self.testTrackingManager.trackEventCalls[0].eventName!)
        }
    }
}
