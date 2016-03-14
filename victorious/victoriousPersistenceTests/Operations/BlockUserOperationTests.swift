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
    var conversation: VConversation!
    let conversationID = 12345
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
        
        conversation = persistentStoreHelper.createConversation(remoteId: conversationID)
        conversation.user = objectUser
        
        testStore.mainContext.v_save()
    }
    
    override func tearDown() {
        super.tearDown()
        testStore.mainContext.v_performBlockAndWait { context in
            if !self.conversation.hasBeenDeleted {
                context.deleteObject(self.conversation)
            }
            context.deleteObject(self.currentUser)
            context.deleteObject(self.objectUser)
            context.v_save()
        }
    }
    
    func testOperationNotRunWithoutConfirmation() {
        operation = BlockUserOperation(userID: objectUser.remoteId.integerValue, conversationID: conversationID)
        
        let confirm = MockActionConfirmationOperation(shouldConfirm: false)
        confirm.before(operation).queue()
        
        let expectation = expectationWithDescription("BlockUserOperation")
        operation.queue() { results, error, cancelled in
            XCTFail("Should not be called")
        }
        dispatch_after(1.0) {
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(expectationThreshold) { error in
            let dependentOperations = self.operation.v_defaultQueue.v_dependentOperationsOf(self.operation)
            XCTAssertEqual( dependentOperations.count, 0 )
        }
        XCTAssertFalse(conversation.hasBeenDeleted)
    }
    
    func testWithoutConversationID() {
        operation = BlockUserOperation(userID: objectUser.remoteId.integerValue)
        
        let context = testStore.mainContext
        var sequences = [VSequence]()
        sequences = context.v_findObjects(["user.remoteId" : objectUser.remoteId.integerValue])
        
        XCTAssertFalse(objectUser.isBlockedByMainUser.boolValue)
        XCTAssertNotEqual(sequences.count, 0)
        
        let expectation = expectationWithDescription("BlockUserOperation")
        operation.queue() { results, error, cancelled in
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
    
    func testWithConversationID() {
        operation = BlockUserOperation(userID: objectUser.remoteId.integerValue, conversationID: conversationID)
        
        let context = testStore.mainContext
        var sequences = [VSequence]()
        sequences = context.v_findObjects(["user.remoteId" : objectUser.remoteId.integerValue])
        
        XCTAssertFalse(objectUser.isBlockedByMainUser.boolValue)
        XCTAssertNotEqual(sequences.count, 0)
        
        let expectation = expectationWithDescription("BlockUserOperation")
        operation.queue() { results, error, cancelled in
            XCTAssertNil(error)
            let dependentOperations = self.operation.v_defaultQueue.v_dependentOperationsOf(self.operation).flatMap { $0 as? BlockUserRemoteOperation }
            XCTAssertEqual( dependentOperations.count, 1 )
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(expectationThreshold, handler:nil)
        
        sequences = context.v_findObjects(["user.remoteId" : objectUser.remoteId.integerValue])
        XCTAssertEqual(sequences.count, 0)
        XCTAssertTrue(objectUser.isBlockedByMainUser.boolValue)
        
        XCTAssert(conversation.hasBeenDeleted)
    }
}
