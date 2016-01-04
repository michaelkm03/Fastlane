//
//  FollowUserOperationTest.swift
//  victorious
//
//  Created by Alex Tamoykin on 12/21/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class FollowUserOperationTest: XCTestCase {
    let expectationThreshold: Double = 10
    var operation: FollowUserOperation!
    var testStore: TestPersistentStore!
    var testTrackingManager: TestTrackingManager!
    var testRequestExecutor: TestRequestExecutor!
    let userToFollowID = Int64(1)
    let currentUserID = Int64(2)
    let screenName = "screenName"
    let operationHelper = RequestOperationTestHelper()

    override func setUp() {
        super.setUp()
        testStore = TestPersistentStore()
        operation = FollowUserOperation(userToFollowID: userToFollowID, currentUserID: currentUserID, screenName: screenName)
        testTrackingManager = TestTrackingManager()
        testRequestExecutor = TestRequestExecutor()
        operation.persistentStore = testStore
        operation.trackingManager = testTrackingManager
        operation.requestExecutor = testRequestExecutor
    }


    func __testFollowingAnExistentUser() {
        let createdCurrentUser = operationHelper.createUser(remoteId: currentUserID, persistentStore: testStore)
        let createdUserToFollow = operationHelper.createUser(remoteId: userToFollowID, persistentStore: testStore)
        let expectation = expectationWithDescription("operation expectation")
        operation.queue { error in
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(expectationThreshold) { error in
            guard let updatedUserToFollow = self.testStore.mainContext.objectWithID(createdUserToFollow.objectID) as? VUser else {
                XCTFail("No user to follow found after following a user")
                return
            }

            guard let updatedCurrentUser = self.testStore.mainContext.objectWithID(createdCurrentUser.objectID) as? VUser else {
                XCTFail("No current user found after following a user")
                return
            }
            XCTAssertEqual(1, updatedUserToFollow.numberOfFollowers)
            XCTAssertEqual(1, updatedCurrentUser.numberOfFollowing)
            XCTAssertEqual(1, updatedCurrentUser.following.count)
            XCTAssert(updatedCurrentUser.following.contains(updatedUserToFollow))
            XCTAssertEqual(true, updatedUserToFollow.isFollowedByMainUser)
            XCTAssertEqual(1, self.testTrackingManager.trackEventCalls.count)
            XCTAssertEqual(VTrackingEventUserDidFollowUser, self.testTrackingManager.trackEventCalls[0].eventName!)
            XCTAssertEqual(1, self.testRequestExecutor.executeRequestCallCount)
        }
    }

    func __testFollowingANonExistentUser() {
        let existingUsers: [VUser] = self.testStore.mainContext.v_findAllObjects()
        XCTAssertEqual(0, existingUsers.count)

        let expectation = expectationWithDescription("operation expectation")
        operation.queue { error in
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(expectationThreshold) { error in
            if let createdUsers: [VUser] = self.testStore.mainContext.v_findAllObjects() where createdUsers.count > 0 {
                XCTFail("following a non existent user created new users \(createdUsers) which it shouldn't do")
            }
            XCTAssertEqual(1, self.testTrackingManager.trackEventCalls.count)
            XCTAssertEqual(VTrackingEventUserDidFollowUser, self.testTrackingManager.trackEventCalls[0].eventName!)
        }
    }

    override func tearDown() {
        super.tearDown()
        operationHelper.tearDownPersistentStore(store: testStore)
    }
}
