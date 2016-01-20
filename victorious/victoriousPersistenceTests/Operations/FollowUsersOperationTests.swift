//
//  FollowUsersOperationTests.swift
//  victorious
//
//  Created by Alex Tamoykin on 12/21/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
@testable import victorious
@testable import VictoriousIOSSDK

class FollowUsersOperationTests: BaseRequestOperationTestCase {
    var operation: FollowUsersOperation!
    let currentUserID = 1
    let userIDOne = 2
    let userIDTwo = 3
    let nonExistentUserID = 4
    lazy var userIDs: [Int] = {
        return [self.nonExistentUserID, self.userIDOne, self.userIDTwo]
    }()

    override func setUp() {
        super.setUp()
        self.continueAfterFailure = false
        operation = FollowUsersOperation(userID: userIDOne, sourceScreenName: "profile")
        operation.eventTracker = testTrackingManager
        operation.requestExecutor = testRequestExecutor
    }

    func testFollowingAnExistentUser() {
        let createdCurrentUser = persistentStoreHelper.createUser(remoteId: currentUserID)
        createdCurrentUser.setAsCurrentUser()
        
        let createdUserToFollow = persistentStoreHelper.createUser(remoteId: userIDOne)
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

    func testBatchFollowingExistentAndNonExistentUsers() {
        operation = FollowUsersOperation(userIDs: userIDs)
        operation.requestExecutor = testRequestExecutor
        let userOne = persistentStoreHelper.createUser(remoteId: userIDOne)
        let userTwo = persistentStoreHelper.createUser(remoteId: userIDTwo)
        let currentUser = persistentStoreHelper.createUser(remoteId: currentUserID)
        currentUser.setAsCurrentUser()

        operation.main()

        assertCurrentUserFollowedUsers(userOneObjectID: userOne.objectID, userTwoObjectID: userTwo.objectID)
    }

    func testBatchFollowOnlyExistentUsers() {
        operation = FollowUsersOperation(userIDs: [self.userIDOne, self.userIDTwo])
        operation.requestExecutor = testRequestExecutor
        let userOne = persistentStoreHelper.createUser(remoteId: userIDOne)
        let userTwo = persistentStoreHelper.createUser(remoteId: userIDTwo)
        let currentUser = persistentStoreHelper.createUser(remoteId: currentUserID)
        currentUser.setAsCurrentUser()

        operation.main()

        assertCurrentUserFollowedUsers(userOneObjectID: userOne.objectID, userTwoObjectID: userTwo.objectID)
    }

    func testBatchFollowUsersWhosIDMatchesACurrentUser() {
        operation = FollowUsersOperation(userIDs: [self.userIDOne, self.userIDTwo, currentUserID])
        operation.requestExecutor = testRequestExecutor
        let userOne = persistentStoreHelper.createUser(remoteId: userIDOne)
        let userTwo = persistentStoreHelper.createUser(remoteId: userIDTwo)
        persistentStoreHelper.createUser(remoteId: currentUserID)
        let currentUser = persistentStoreHelper.createUser(remoteId: currentUserID)
        currentUser.setAsCurrentUser()

        operation.main()

        assertCurrentUserFollowedUsers(userOneObjectID: userOne.objectID, userTwoObjectID: userTwo.objectID)
    }

    private func assertCurrentUserFollowedUsers(userOneObjectID userOneObjectID: NSManagedObjectID, userTwoObjectID: NSManagedObjectID) {
        guard let userOne = self.testStore.mainContext.objectWithID(userOneObjectID) as? VUser else {
            XCTFail("No user to follow found after following a user")
            return
        }
        guard let userTwo = self.testStore.mainContext.objectWithID(userTwoObjectID) as? VUser else {
            XCTFail("No user to follow found after following a user")
            return
        }
        guard let currentUser = VCurrentUser.user() else {
            XCTFail("No current user found after following a user")
            return
        }

        XCTAssertEqual(2, currentUser.numberOfFollowing)
        XCTAssertEqual(2, currentUser.following.count)
        if let followedUsers = Array(currentUser.following) as? [VFollowedUser] {
            let objectUsersObjectIDs = followedUsers.map { $0.objectUser.objectID }
            let subjectUserIDs = followedUsers.map { $0.subjectUser.objectID }
            XCTAssert(objectUsersObjectIDs.contains(userOne.objectID))
            XCTAssert(objectUsersObjectIDs.contains(userTwo.objectID))
            XCTAssertEqual(2, subjectUserIDs.count)
            for id in subjectUserIDs {
                XCTAssertEqual(currentUser.objectID, id)
            }
        } else {
            XCTFail("Couldn't find a followed user after following multiple users")
        }

        XCTAssertEqual(1, userOne.numberOfFollowers)
        XCTAssertEqual(true, userOne.isFollowedByMainUser)
        XCTAssertEqual(1, userOne.followers.count)
        if let followedUser = Array(userOne.followers)[0] as? VFollowedUser {
            XCTAssertEqual(followedUser.objectUser, userOne)
            XCTAssertEqual(followedUser.subjectUser, currentUser)
        } else {
            XCTFail("Couldn't find a followed user after following multiple users")
        }

        XCTAssertEqual(true, userTwo.isFollowedByMainUser)
        XCTAssertEqual(1, userTwo.numberOfFollowers)
        if let followedUser = Array(userTwo.followers)[0] as? VFollowedUser {
            XCTAssertEqual(followedUser.objectUser, userTwo)
            XCTAssertEqual(followedUser.subjectUser, currentUser)
        } else {
            XCTFail("Couldn't find a followed user after following multiple users")
        }

        XCTAssertEqual(1, testRequestExecutor.executeRequestCallCount)
    }

}
