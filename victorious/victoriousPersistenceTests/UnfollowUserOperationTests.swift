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
        VCurrentUser.persistentStore = testStore
        operation = UnfollowUserOperation(userID: userID, screenName: screenName)
        operation.requestExecutor = testRequestExecutor
        operation.trackingManager = testTrackingManager
    }

    func testUnfollowingAnExistingUser() {
        let currentUser = operationHelper.createUser(remoteId: currentUserID, persistentStore: testStore)
        currentUser.setAsCurrentUser()

        let objectUser = operationHelper.createUser(remoteId: userID, persistentStore: testStore)
        objectUser.isFollowedByMainUser = true
        objectUser.numberOfFollowers = 1
        currentUser.numberOfFollowing = 1
        let uniqueElements = [ "subjectUser" : currentUser, "objectUser" : objectUser ]
        let followedUser: VFollowedUser = testStore.mainContext.v_findOrCreateObject( uniqueElements )
        followedUser.displayOrder = -1
        followedUser.objectUser = objectUser
        followedUser.subjectUser = currentUser
        testStore.mainContext.v_save()

        operation.main()

        XCTAssertEqual(1, testTrackingManager.trackEventCalls.count)
        XCTAssertEqual(VTrackingEventUserDidUnfollowUser, testTrackingManager.trackEventCalls[0].eventName!)
    }

    override func tearDown() {
        super.tearDown()
        operationHelper.tearDownPersistentStore(store: testStore)
    }
}
