//
//  UnfollowUserOperationTests.swift
//  victorious
//
//  Created by Alex Tamoykin on 1/2/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class UnfollowUserOperationTests: XCTestCase {
    var operation: UnfollowUserOperation!
    var testStore: TestPersistentStore!
    var testRequestExecutor: TestRequestExecutor!
    var testTrackingManager: TestTrackingManager!
    let userID = 1
    let currentUserID = 2
    let screenName = "screenName"
    let operationHelper = RequestOperationTestHelper()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        testStore = TestPersistentStore()
        testTrackingManager = TestTrackingManager()
        testRequestExecutor = TestRequestExecutor()
        operation = UnfollowUserOperation(userID: userID, screenName: screenName)
        operation.requestExecutor = testRequestExecutor
        operation.trackingManager = testTrackingManager
    }

    func testUnfollowingAnExistingUser() {
        let objectUser = operationHelper.createUser(remoteId: userID, persistentStore: testStore)
        let currentUser = operationHelper.createUser(remoteId: currentUserID, persistentStore: testStore)
        currentUser.setAsCurrentUser()

        objectUser.isFollowedByMainUser = true
        objectUser.numberOfFollowers = 1
        currentUser.numberOfFollowing = 1
        let uniqueElements = [ "subjectUser" : currentUser, "objectUser" : objectUser ]
        let followedUser: VFollowedUser = testStore.mainContext.v_findOrCreateObject( uniqueElements )
        followedUser.objectUser = objectUser
        followedUser.subjectUser = currentUser
        followedUser.displayOrder = -1
        testStore.mainContext.v_save()

        operation.main()

        guard let updatedUser = testStore.mainContext.objectWithID(objectUser.objectID) as? VUser else {
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
        XCTAssertEqual(1, testTrackingManager.trackEventCalls.count)
        XCTAssertEqual(false, updatedUser.isFollowedByMainUser)
        XCTAssertEqual(VTrackingEventUserDidUnfollowUser, testTrackingManager.trackEventCalls[0].eventName!)
    }

    override func tearDown() {
        super.tearDown()
        operationHelper.tearDownPersistentStore(store: testStore)
    }
}
