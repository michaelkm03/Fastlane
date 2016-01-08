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

class FollowUserOperationTests: XCTestCase {
    var operation: FollowUserOperation!
    var testStore: TestPersistentStore!
    var testTrackingManager: TestTrackingManager!
    var testRequestExecutor: TestRequestExecutor<FollowUserRequest>!
    let userID: Int = 1
    let currentUserID: Int = 2
    let screenName = "screenName"
    let operationHelper = RequestOperationTestHelper()

    override func setUp() {
        super.setUp()
        self.continueAfterFailure = false
        testStore = TestPersistentStore()
        testTrackingManager = TestTrackingManager()
        testRequestExecutor = TestRequestExecutor()
        operation = FollowUserOperation(userID: userID, screenName: screenName)
        operation.eventTracker = testTrackingManager
        operation.requestExecutor = testRequestExecutor
    }

    func testFollowingAnExistentUser() {
        let createdCurrentUser = operationHelper.createUser(remoteId: currentUserID, persistentStore: testStore)
        createdCurrentUser.setAsCurrentUser()
        
        let createdUserToFollow = operationHelper.createUser(remoteId: userID, persistentStore: testStore)
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
        if updatedUserToFollow.followers.count == 1, let user = Array(updatedUserToFollow.followers)[0] as? VUser {
            XCTAssertEqual( user, updatedUserToFollow )
        }
        
        XCTAssertEqual(1, currentUser.numberOfFollowing)
        XCTAssertEqual(1, currentUser.following.count)
        if currentUser.following.count == 1, let user = Array(currentUser.following)[0] as? VUser {
            XCTAssertEqual(user, updatedUserToFollow)
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

    override func tearDown() {
        super.tearDown()
        operationHelper.tearDownPersistentStore(store: testStore)
    }
}
