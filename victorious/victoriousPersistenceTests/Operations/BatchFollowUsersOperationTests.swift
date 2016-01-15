//
//  BatchFollowUsersOperationTests.swift
//  victorious
//
//  Created by Alex Tamoykin on 1/7/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class BatchFollowUsersOperationTests: BaseRequestOperationTestCase {
    var operation: BatchFollowUsersOperation!
    let currentUserID = 1
    let userIDOne = 2
    let userIDTwo = 3
    let nonExistentUserID = 4
    lazy var userIDs: [Int] = {
        return [self.nonExistentUserID, self.userIDOne, self.userIDTwo]
    }()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testBatchFollowingExistentAndNonExistentUsers() {
        operation = BatchFollowUsersOperation(userIDs: userIDs)
        operation.requestExecutor = testRequestExecutor
        let userOne = persistentStoreHelper.createUser(remoteId: userIDOne)
        let userTwo = persistentStoreHelper.createUser(remoteId: userIDTwo)
        let currentUser = persistentStoreHelper.createUser(remoteId: currentUserID)
        currentUser.setAsCurrentUser()

        operation.main()

        assertCurrentUserFollowedUsers(userOneObjectID: userOne.objectID, userTwoObjectID: userTwo.objectID)
    }

    func testBatchFollowOnlyExistentUsers() {
        operation = BatchFollowUsersOperation(userIDs: [self.userIDOne, self.userIDTwo])
        operation.requestExecutor = testRequestExecutor
        let userOne = persistentStoreHelper.createUser(remoteId: userIDOne)
        let userTwo = persistentStoreHelper.createUser(remoteId: userIDTwo)
        let currentUser = persistentStoreHelper.createUser(remoteId: currentUserID)
        currentUser.setAsCurrentUser()

        operation.main()

        assertCurrentUserFollowedUsers(userOneObjectID: userOne.objectID, userTwoObjectID: userTwo.objectID)
    }

    func testBatchFollowUsersWhosIDMatchesACurrentUser() {
        operation = BatchFollowUsersOperation(userIDs: [self.userIDOne, self.userIDTwo, currentUserID])
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
