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
    let expectationThreshold: Double = 2
    var operation: FollowUserOperation!
    var testStore: TestPersistentStore!
    var testTrackingManager: TestTrackingManager!
    var testRequestExecutor: TestRequestExecutor!
    let userToFollowID: Int64 = 1
    let currentUserID: Int64 = 2
    let screenName = "screenName"

    override func setUp() {
        super.setUp()
        testStore = TestPersistentStore()
        testTrackingManager = TestTrackingManager()
        testRequestExecutor = TestRequestExecutor()
        VCurrentUser.persistentStore = testStore

        operation = FollowUserOperation(userID: userToFollowID, screenName: screenName)
        operation.persistentStore = testStore
        operation.eventTracker = testTrackingManager
        operation.requestExecutor = testRequestExecutor
    }

    func testFollowingAnExistentUser() {
        
        let createdCurrentUser = createUser(remoteId: currentUserID)
        createdCurrentUser.setAsCurrentUser()

        guard let currentUser = VCurrentUser.user( inManagedObjectContext: operation.persistentStore.backgroundContext ) else {
            XCTFail("No current user found!")
            return
        }
    
        let createdUserToFollow = createUser(remoteId: userToFollowID)
        queueExpectedOperation(operation: operation)

        waitForExpectationsWithTimeout(expectationThreshold) { error in
            guard let updatedUserToFollow = self.testStore.mainContext.objectWithID(createdUserToFollow.objectID) as? VUser else {
                XCTFail("No user to follow found after following a user")
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
            XCTAssertEqual(1, self.testRequestExecutor.executeRequestCallCount)
        }
    }

    func testFollowingANonExistentUser() {
        let existingUsers: [VUser] = self.testStore.mainContext.v_findAllObjects()
        XCTAssertEqual(0, existingUsers.count)

        queueExpectedOperation(operation: operation)
        waitForExpectationsWithTimeout(expectationThreshold) { error in
            if let createdUsers: [VUser] = self.testStore.mainContext.v_findAllObjects() where createdUsers.count > 0 {
                XCTFail("following a non existent user created new users \(createdUsers) which it shouldn't do")
            }
            XCTAssertEqual(1, self.testTrackingManager.trackEventCalls.count)
            if self.testTrackingManager.trackEventCalls.count >= 1 {
                XCTAssertEqual(VTrackingEventUserDidFollowUser, self.testTrackingManager.trackEventCalls[0].eventName!)
            }
            XCTAssertEqual(0, self.testRequestExecutor.executeRequestCallCount)
        }
    }

    override func tearDown() {
        do {
            try testStore.deletePersistentStore()
        } catch PersistentStoreError.DeleteFailed(let storeURL, let error) {
            XCTFail("Failed to clear the test persistent store at \(storeURL) because of \(error)." +
                "Failing this test since it can cause test pollution.")
        } catch {
            XCTFail("Something went wrong while clearing persitent store")
        }
    }

    private func queueExpectedOperation(operation operation: FollowUserOperation) -> XCTestExpectation {
        let expectation = expectationWithDescription("operation completed")
        operation.queue() { error in
            expectation.fulfill()
        }
        return expectation
    }

    private func createUser(remoteId remoteId: Int64) -> VUser {
        return testStore.mainContext.v_createObjectAndSave { user in
            user.remoteId = NSNumber(longLong: remoteId)
            user.status = "stored"
        } as VUser
    }
}
