//
//  SequenceDeleteOperationTests.swift
//  victorious
//
//  Created by Patrick Lynch on 3/2/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class SequenceDeleteOperationTests: BaseFetcherOperationTestCase {
    
    func testWithConfirmation() {
        let sequence = persistentStoreHelper.createSequence(remoteId: "9432")
        
        let operation = SequenceDeleteOperation(sequenceID: sequence.remoteId)
        
        let confirm = MockActionConfirmationOperation(shouldConfirm: true)
        confirm.before(operation).queue()
        
        let expectation = expectationWithDescription("SequenceDeleteOperation")
        operation.queue() { results, error, cancelled in
            
            XCTAssertNil( error )
            let dependentOperations = operation.v_defaultQueue.v_dependentOperationsOf(operation).flatMap { $0 as? SequenceDeleteRemoteOperation }
            XCTAssertEqual( dependentOperations.count, 1 )
            
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(expectationThreshold, handler: nil)
    }
    
    func testWithoutConfirmation() {
        let sequence = persistentStoreHelper.createSequence(remoteId: "9432")
        
        let operation = SequenceDeleteOperation(sequenceID: sequence.remoteId)
        
        let confirm = MockActionConfirmationOperation(shouldConfirm: false)
        confirm.before(operation).queue()
        
        let expectation = expectationWithDescription("SequenceDeleteOperation")
        operation.queue() { results, error, cancelled in
            XCTFail("Should not be called")
        }
        dispatch_after(0.2) {
            expectation.fulfill()
        }
        operation.v_defaultQueue.suspended = true
        waitForExpectationsWithTimeout(expectationThreshold) { error in
            let dependentOperations = operation.v_defaultQueue.v_dependentOperationsOf(operation)
            XCTAssertEqual( dependentOperations.count, 0 )
        }
    }
}
