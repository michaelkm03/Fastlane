//
//  ToggleLikeSequenceOperationTests.swift
//  victorious
//
//  Created by Vincent Ho on 3/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class ToggleLikeSequenceOperationTests: XCTestCase {
    
    var sequence: VSequence?
    let sequenceRemoteId = "12345"
    let userRemoteId = 54321
    
    var expectation: XCTestExpectation?
    
    var persistentStoreHelper: PersistentStoreTestHelper!
    var testStore: TestPersistentStore!

    override func setUp() {
        super.setUp()
        testStore = TestPersistentStore()
        testStore.deletePersistentStore()
        persistentStoreHelper = PersistentStoreTestHelper(persistentStore: testStore)
        expectation = expectationWithDescription("Finished Operation")

        let user = persistentStoreHelper.createUser(remoteId: userRemoteId)
        user.setAsCurrentUser()
    }
    
    func setupSequenceLiked(liked: Bool) {
        sequence = persistentStoreHelper.createEmptySequence(remoteId: sequenceRemoteId)
        sequence?.isLikedByMainUser = liked ? 1 : 0
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testInitiallyLiked() {
        setupSequenceLiked(true)
        XCTAssert(sequence?.isLikedByMainUser.boolValue == true)
        XCTAssert(sequence?.objectID != nil)
        let objectId: NSManagedObjectID = (sequence?.objectID)!
        
        ToggleLikeSequenceOperation(sequenceObjectId: objectId).queue() { results, error in
            XCTAssert(self.sequence?.isLikedByMainUser.boolValue == false);
            self.expectation?.fulfill()
        }
        waitForExpectationsWithTimeout(5,
            handler: nil)
    }
}
