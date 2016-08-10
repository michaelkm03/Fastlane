//
//  ContentFlagOperationTests.swift
//  victorious
//
//  Created by Vincent Ho on 6/2/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class ContentFlagOperationTests: BaseFetcherOperationTestCase {
    func testWithConfirmation() {
        let operation = ContentFlagOperation(contentID: "12345", apiPath: APIPath(templatePath: ""))
        
        let confirm = MockActionConfirmationOperation(shouldConfirm: true)
        confirm.before(operation).queue()
        
        let expectation = expectationWithDescription("ContentFlagOperation")
        operation.queue() { results, error, cancelled in
            
            XCTAssertNil( error )
            let dependentOperations = operation.v_defaultQueue.v_dependentOperationsOf(operation).flatMap { $0 as? ContentFlagRemoteOperation }
            XCTAssertEqual( dependentOperations.count, 1 )
            
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(expectationThreshold, handler: nil)
    }
    
    func testWithoutConfirmation() {
        let operation = ContentFlagOperation(contentID: "12345", apiPath: APIPath(templatePath: ""))
        
        let confirm = MockActionConfirmationOperation(shouldConfirm: false)
        confirm.before(operation).queue()
        
        let expectation = expectationWithDescription("ContentFlagOperation")
        operation.queue() { results, error, cancelled in
            XCTFail("Should not be called")
        }
        dispatch_after(expectationThreshold/2) {
            expectation.fulfill()
        }
        operation.v_defaultQueue.suspended = true
        waitForExpectationsWithTimeout(expectationThreshold) { error in
            let dependentOperations = operation.v_defaultQueue.v_dependentOperationsOf(operation)
            XCTAssertEqual( dependentOperations.count, 0 )
        }
    }
}
