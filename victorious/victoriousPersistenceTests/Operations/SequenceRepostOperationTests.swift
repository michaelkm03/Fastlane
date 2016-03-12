//
//  SequenceRepostOperationTests.swift
//  victorious
//
//  Created by Vincent Ho on 3/2/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class SequenceRepostOperationTests: BaseFetcherOperationTestCase {
    var user: VUser?
    var sequence: VSequence?
    
    let sequenceRemoteId = "12345"
    let userRemoteId = 12345
    
    override func setUp() {
        super.setUp()
        
        sequence = persistentStoreHelper.createSequence(remoteId: sequenceRemoteId)
        sequence?.repostCount = 0
        sequence?.hasBeenRepostedByMainUser = false
        
        let node: VNode = persistentStoreHelper.createNode(123, sequence: sequence!)
        sequence?.v_addObject(node, to: "nodes")
        
        user = persistentStoreHelper.createUser(remoteId: userRemoteId)
        user?.setAsCurrentUser()
    }

    func testRepostSequence() {
        let expectation = expectationWithDescription("Finished Operation")
        let operation = SequenceRepostOperation(sequenceID: sequenceRemoteId)
        operation.queue() { results, error, cancelled in
            XCTAssertNotNil(self.sequence)
            XCTAssertNotNil(self.user)
            guard let sequence: VSequence = self.sequence, user = self.user else {
                XCTFail("Sequence or user should not be nil")
                return
            }
            XCTAssert(sequence.hasReposted.boolValue)
            XCTAssertEqual(sequence.hasReposted.integerValue, 1)
            XCTAssert( (user.repostedSequences ?? Set<NSObject>()).contains(sequence) )
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: nil)
    }
}
