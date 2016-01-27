//
//  UnfollowUsersOperationTests.swift
//  victorious
//
//  Created by Alex Tamoykin on 1/2/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious
@testable import VictoriousIOSSDK

class UnfollowUsersOperationTests: BaseRequestOperationTestCase {
    var operation: UnFollowUsersOperation!
    let userID = 1
    let currentUserID = 2

    override func setUp() {
        super.setUp()
        operation = UnFollowUsersOperation(userID: userID, sourceScreenName: "profile")
        operation.requestExecutor = testRequestExecutor
        operation.trackingManager = testTrackingManager
    }

    func testUnfollowingAnExistingUser() {
        let objectUser = persistentStoreHelper.createUser(remoteId: userID)
        let currentUser = persistentStoreHelper.createUser(remoteId: currentUserID)
        currentUser.setAsCurrentUser()

        objectUser.isFollowedByMainUser = true
        objectUser.numberOfFollowers = 1
        currentUser.numberOfFollowing = 1
        
        testStore.mainContext.v_performBlockAndWait() { context in
            let uniqueElements = [ "subjectUser" : currentUser, "objectUser" : objectUser ]
            let followedUser: VFollowedUser = context.v_findOrCreateObject( uniqueElements )
            followedUser.objectUser = objectUser
            followedUser.subjectUser = currentUser
            followedUser.displayOrder = -1
            context.v_save()
        }

        queueExpectedOperation(operation: operation)
        waitForExpectationsWithTimeout(expectationThreshold) { error in
            XCTAssertEqual(1, self.testRequestExecutor.executeRequestCallCount)
            guard let updatedUser = self.testStore.mainContext.objectWithID(objectUser.objectID) as? VUser else {
                XCTFail("No user to follow found after following a user")
                return
            }
            guard let updatedCurrentUser = VCurrentUser.user() else {
                XCTFail("No current user found after following a user")
                return
            }

            XCTAssertEqual(0, updatedUser.numberOfFollowers)
            XCTAssertEqual(0, updatedUser.followers.count)
            XCTAssertEqual(0, updatedCurrentUser.numberOfFollowing)
            XCTAssertEqual(0, updatedCurrentUser.following.count)
            XCTAssertEqual(false, updatedUser.isFollowedByMainUser)
            
            self.continueAfterFailure = false
            XCTAssertEqual(1, self.testTrackingManager.trackEventCalls.count)
            XCTAssertEqual(VTrackingEventUserDidUnfollowUser, self.testTrackingManager.trackEventCalls[0].eventName!)
        }
    }
}
