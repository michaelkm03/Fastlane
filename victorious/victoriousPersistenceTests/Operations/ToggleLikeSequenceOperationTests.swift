//
//  ToggleLikeSequenceOperationTests.swift
//  victorious
//
//  Created by Vincent Ho on 3/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class ToggleLikeSequenceOperationTests: BaseFetcherOperationTestCase {
    
    var sequence: VSequence?
    let sequenceRemoteId = "12345"
    let userRemoteId = 54321

    override func setUp() {
        super.setUp()
        let user = persistentStoreHelper.createUser(remoteId: userRemoteId)
        user.setAsCurrentUser()
    }

    func testInitiallyLiked() {
        sequence = persistentStoreHelper.createSequence(remoteId: sequenceRemoteId)
        sequence?.isLikedByMainUser = true
        
        XCTAssert(sequence?.isLikedByMainUser.boolValue == true)
        XCTAssert(sequence?.objectID != nil)
        let objectId: NSManagedObjectID = (sequence?.objectID)!
        
        let expectation = expectationWithDescription("ToggleLikeSequenceOperation")
        let operation = ToggleLikeSequenceOperation(sequenceObjectId: objectId)
        operation.queue() { results, error in
            XCTAssert(self.sequence?.isLikedByMainUser.boolValue == false);
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(expectationThreshold, handler: nil)
    }
}
