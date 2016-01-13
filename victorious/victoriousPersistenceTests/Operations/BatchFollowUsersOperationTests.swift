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
    let userIDOne = 1
    let userIDTwo = 2
    lazy var userIDs: [Int] = {
        return [self.userIDOne, self.userIDTwo]
    }()
    let currentUserID = 1

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        operation = BatchFollowUsersOperation(userIDs: userIDs)
        operation.requestExecutor = testRequestExecutor
    }

    func testBatchFollowingUsers() {
        let userOne = persistentStoreHelper.createUser(remoteId: userIDOne)
        let userTwo = persistentStoreHelper.createUser(remoteId: userIDTwo)
        let currentUser = persistentStoreHelper.createUser(remoteId: currentUserID)
        currentUser.setAsCurrentUser()

        operation.main()

        guard let updatedUserOne = self.testStore.mainContext.objectWithID(userOne.objectID) as? VUser else {
            XCTFail("No user to follow found after following a user")
            return
        }
        guard let updatedUserTwo = self.testStore.mainContext.objectWithID(userTwo.objectID) as? VUser else {
            XCTFail("No user to follow found after following a user")
            return
        }
        guard let updatedCurrentUser = VCurrentUser.user() else {
            XCTFail("No current user found after following a user")
            return
        }

        XCTAssertEqual(2, updatedCurrentUser.numberOfFollowing)
        XCTAssertEqual(2, updatedCurrentUser.following.count)
        if let followedUsers = Array(updatedCurrentUser.following) as? [VFollowedUser] {
            let objectUsersObjectIDs = followedUsers.map { $0.objectUser.objectID }
            let subjectUserIDs = followedUsers.map { $0.subjectUser.objectID }
            XCTAssert(objectUsersObjectIDs.contains(updatedUserOne.objectID))
            XCTAssert(objectUsersObjectIDs.contains(updatedUserTwo.objectID))
            XCTAssertEqual(2, subjectUserIDs.count)
            for id in subjectUserIDs {
                XCTAssertEqual(updatedCurrentUser.objectID, id)
            }
        } else {
            XCTFail("Couldn't find a followed user after following multiple users")
        }

        XCTAssertEqual(1, updatedUserOne.numberOfFollowers)
        XCTAssertEqual(true, updatedUserOne.isFollowedByMainUser)
        XCTAssertEqual(1, updatedUserOne.followers.count)
        if let followedUser = Array(updatedUserOne.followers)[0] as? VFollowedUser {
            XCTAssertEqual(followedUser.objectUser, updatedUserOne)
            XCTAssertEqual(followedUser.subjectUser, updatedCurrentUser)
        } else {
            XCTFail("Couldn't find a followed user after following multiple users")
        }

        XCTAssertEqual(true, updatedUserTwo.isFollowedByMainUser)
        XCTAssertEqual(1, updatedUserTwo.numberOfFollowers)
        if let followedUser = Array(updatedUserTwo.followers)[0] as? VFollowedUser {
            XCTAssertEqual(followedUser.objectUser, updatedUserTwo)
            XCTAssertEqual(followedUser.subjectUser, updatedCurrentUser)
        } else {
            XCTFail("Couldn't find a followed user after following multiple users")
        }

        XCTAssertEqual(1, testRequestExecutor.executeRequestCallCount)
    }
}
