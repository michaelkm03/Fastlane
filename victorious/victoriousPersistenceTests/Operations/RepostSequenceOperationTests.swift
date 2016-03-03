//
//  RepostSequenceOperationTests.swift
//  victorious
//
//  Created by Vincent Ho on 3/2/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class RepostSequenceOperationTests: XCTestCase {
    var user: VUser?
    var sequence: VSequence?
    
    let sequenceRemoteId = "12345"
    let userRemoteId = 12345
    var expectation: XCTestExpectation?
    
    var persistentStoreHelper: PersistentStoreTestHelper!
    var testStore: TestPersistentStore!
    
    override func setUp() {
        super.setUp()
        
        testStore = TestPersistentStore()
        testStore.deletePersistentStore()
        persistentStoreHelper = PersistentStoreTestHelper(persistentStore: testStore)
        
        sequence = persistentStoreHelper.createEmptySequence(remoteId: sequenceRemoteId)
        
        let node: VNode = persistentStoreHelper.createNode(123, sequence: sequence!)
        sequence?.v_addObject(node, to: "nodes")
        
        user = persistentStoreHelper.createUser(remoteId: userRemoteId)
        user?.setAsCurrentUser()

        expectation = expectationWithDescription("Finished Operation")
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func returnUser() -> VUser?{
        return self.user
    }

    func testRepostSequence() {
        RepostSequenceOperation(sequenceID: sequenceRemoteId).queue() { results, error in
            XCTAssert(self.sequence != nil)
            XCTAssert(self.user != nil)
            guard let sequence: VSequence = self.sequence,
                user = self.user else {
                XCTFail()
                return
            }
            XCTAssert(sequence.hasReposted.boolValue);
            
            XCTAssert(sequence.hasReposted.integerValue == 1);
            
            XCTAssert(user.repostedSequences.contains(sequence));
            self.expectation?.fulfill()
        }
        waitForExpectationsWithTimeout(5,
            handler: { error in
                if let error = error {
                    XCTFail("timeout error: \(error)")
                }
        })
    }
}
