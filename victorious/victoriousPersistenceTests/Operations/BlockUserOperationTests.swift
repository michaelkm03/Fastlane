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
    
    let testSequenceCount = 5
    
    override func setUp() {
        super.setUp()
        
        objectUser = persistentStoreHelper.createUser(remoteId: 1)
        currentUser = persistentStoreHelper.createUser(remoteId: 2)
        
        for index in 0..<testSequenceCount {
            let sequence = persistentStoreHelper.createSequence(remoteId: String(index))
            sequence.user = objectUser
        }
        
        currentUser.setAsCurrentUser()
        
        testStore.mainContext.v_save()
        
        operation = BlockUserOperation(userID: objectUser.remoteId.integerValue)
        operation.persistentStore = testStore
    }
    
    func testWithConfirmation() {
        let context = testStore.mainContext
        var sequences = [VSequence]()
        sequences = context.v_findObjects(["user.remoteId" : objectUser.remoteId.integerValue])
        
        XCTAssertFalse(objectUser.isBlockedByMainUser.boolValue)
        XCTAssertNotEqual(sequences.count, 0)
        
        let confirm = MockActionConfirmationOperation(shouldConfirm: true)
        confirm.before(operation).queue()
        
        let expectation = expectationWithDescription("BlockUserOperation")
        operation.queue() { (results, error) in
            XCTAssertNil(error)
            let dependentOperations = self.operation.v_defaultQueue.v_dependentOperationsOf(self.operation).flatMap { $0 as? BlockUserRemoteOperation }
            XCTAssertEqual( dependentOperations.count, 1 )
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(expectationThreshold, handler:nil)
        
        sequences = context.v_findObjects(["user.remoteId" : objectUser.remoteId.integerValue])
        XCTAssertEqual(sequences.count, 0)
        XCTAssertTrue(objectUser.isBlockedByMainUser.boolValue)
    }
    
    func testWithoutConfirmation() {
        let context = testStore.mainContext
        var sequences = [VSequence]()
        sequences = context.v_findObjects(["user.remoteId" : objectUser.remoteId.integerValue])
        
        XCTAssertFalse(objectUser.isBlockedByMainUser.boolValue)
        XCTAssertNotEqual(sequences.count, 0)
        
        let confirm = MockActionConfirmationOperation(shouldConfirm: false)
        confirm.before(operation).queue()
        
        let expectation = expectationWithDescription("BlockUserOperation")
        operation.queue() { (results, error) in
            XCTFail("Should not be called")
        }
        dispatch_after(1.0) {
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(expectationThreshold) { error in
            let dependentOperations = self.operation.v_defaultQueue.v_dependentOperationsOf(self.operation)
            XCTAssertEqual( dependentOperations.count, 0 )
        }
        sequences = context.v_findObjects(["user.remoteId" : objectUser.remoteId.integerValue])
        XCTAssertEqual(sequences.count, testSequenceCount)
        XCTAssertFalse(objectUser.isBlockedByMainUser.boolValue)
    }
}
