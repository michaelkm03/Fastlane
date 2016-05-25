//
//  UnfollowUserOperationTests.swift
//  victorious
//
//  Created by Alex Tamoykin on 1/2/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious
@testable import VictoriousIOSSDK

class UnfollowUserOperationTests: BaseFetcherOperationTestCase {
    var operation: UnfollowUserOperation!
    let userID = 1
    let currentUserID = 2
    
    override func setUp() {
        super.setUp()
        operation = UnfollowUserOperation(userID: userID, sourceScreenName: "profile")
        operation.trackingManager = testTrackingManager
    }
    
    func testUnfollowingAnExistingUser() {
        let objectUser = persistentStoreHelper.createUser(remoteId: userID)
        let currentUser = persistentStoreHelper.createUser(remoteId: currentUserID)
        currentUser.setAsCurrentUser()
        objectUser.isFollowedByMainUser = true
        objectUser.numberOfFollowers = 1
        currentUser.numberOfFollowing = 1

        XCTAssertEqual(0, objectUser.followers?.count)
        XCTAssertEqual(0, currentUser.following?.count)
        XCTAssertEqual(true, objectUser.isFollowedByMainUser)
        XCTAssertFalse( currentUser.isFollowingUserID(objectUser.remoteId.integerValue) )

        let uniqueElements = [ "subjectUser": currentUser, "objectUser": objectUser ]
        let followedUser: VFollowedUser = testStore.mainContext.v_findOrCreateObject( uniqueElements )
        followedUser.objectUser = objectUser
        followedUser.subjectUser = currentUser
        followedUser.displayOrder = -1
        testStore.mainContext.v_save()

        XCTAssertEqual(1, objectUser.numberOfFollowers)
        XCTAssertEqual(1, objectUser.followers?.count)
        XCTAssertEqual(1, currentUser.numberOfFollowing)
        XCTAssertEqual(1, currentUser.following?.count)
        XCTAssertEqual(true, objectUser.isFollowedByMainUser)
        XCTAssert( currentUser.isFollowingUserID(objectUser.remoteId.integerValue) )
        
        operation.main()

        guard let updatedUser = self.testStore.mainContext.objectWithID(objectUser.objectID) as? VUser else {
            XCTFail("No user to follow found after following a user")
            return
        }
        guard let updatedCurrentUser = VCurrentUser.user() else {
            XCTFail("No current user found after following a user")
            return
        }

        XCTAssertEqual(0, updatedUser.numberOfFollowers)
        XCTAssertEqual(0, updatedUser.followers?.count)
        XCTAssertEqual(0, updatedCurrentUser.numberOfFollowing)
        XCTAssertEqual(0, updatedCurrentUser.following?.count)
        XCTAssertEqual(false, updatedUser.isFollowedByMainUser)

        XCTAssertFalse( currentUser.isFollowingUserID(updatedUser.remoteId.integerValue) )

        XCTAssertEqual(1, self.testTrackingManager.trackEventCalls.count)
        XCTAssertEqual(VTrackingEventUserDidUnfollowUser, self.testTrackingManager.trackEventCalls.first?.eventName)

        XCTAssertEqual(0, updatedUser.numberOfFollowers)
        XCTAssertEqual(0, updatedUser.followers?.count)
        XCTAssertEqual(0, updatedCurrentUser.numberOfFollowing)
        XCTAssertEqual(0, updatedCurrentUser.following?.count)
        XCTAssertEqual(false, updatedUser.isFollowedByMainUser)

        self.continueAfterFailure = false
        XCTAssertEqual(1, self.testTrackingManager.trackEventCalls.count)
        XCTAssertEqual(VTrackingEventUserDidUnfollowUser, self.testTrackingManager.trackEventCalls[0].eventName!)
    }
}
