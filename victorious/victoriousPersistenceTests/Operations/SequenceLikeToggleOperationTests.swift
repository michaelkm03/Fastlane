//
//  SequenceLikeToggleOperationTests.swift
//  victorious
//
//  Created by Vincent Ho on 3/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class SequenceLikeToggleOperationTests: BaseFetcherOperationTestCase {
    
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
        
        let expectation = expectationWithDescription("Finished Operation")
        SequenceLikeToggleOperation(sequenceObjectId: objectId).queue() { results, error, cancelled in
            guard let isLiked = self.sequence?.isLikedByMainUser.boolValue else {
                XCTFail()
                return
            }
            XCTAssertFalse(isLiked)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(expectationThreshold, handler: nil)
    }
}
