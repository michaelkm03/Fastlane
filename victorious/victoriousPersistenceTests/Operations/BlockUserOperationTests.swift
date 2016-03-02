//
//  BlockUserOperationTests.swift
//  victorious
//
//  Created by Sharif Ahmed on 2/29/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious
@testable import VictoriousIOSSDK

class BlockUserOperationTests: BaseFetcherOperationTestCase {
    var operation: BlockUserOperation!
    var currentUser: VUser!
    var objectUser: VUser!
    
    override func setUp() {
        super.setUp()
        
        objectUser = persistentStoreHelper.createUser(remoteId: 1)
        currentUser = persistentStoreHelper.createUser(remoteId: 2)
        
        for index in 0..<5 {
            let sequence = persistentStoreHelper.createSequence(remoteId: index)
            sequence.user = objectUser
        }
        
        currentUser.setAsCurrentUser()
        
        testStore.mainContext.v_save()
        
        operation = BlockUserOperation(userID: objectUser.remoteId.integerValue)
        operation.persistentStore = testStore
    }

    func testBlockingUser() {
        let context = testStore.mainContext
        var sequences = [VSequence]()
        sequences = context.v_findObjects(["user.remoteId" : objectUser.remoteId.integerValue])
        
        XCTAssertFalse(objectUser.isBlockedByMainUser.boolValue)
        XCTAssertNotEqual(sequences.count, 0)
        
        let expectation = expectationWithDescription("BlockUserOperation")
        operation.queue() { (results, error) in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(expectationThreshold, handler:nil)
        
        sequences = context.v_findObjects(["user.remoteId" : objectUser.remoteId.integerValue])
        XCTAssertEqual(sequences.count, 0)
        XCTAssertTrue(objectUser.isBlockedByMainUser.boolValue)
    }
}
