//
//  VIPSubscribeOperationTests.swift
//  victorious
//
//  Created by Patrick Lynch on 3/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class VIPPurchasingTests: BasePersistentStoreTestCase {
    
    override func setUp() {
        super.setUp()
        let user = User(id: 12345)
        VCurrentUser.update(to: user)
    }
    
    func testSubscribeSuccess() {
        let operation = VIPSubscribeOperation(productIdentifier: "")
        operation.purchaseManager = MockPurchaseManager()
        
        let expectation = expectationWithDescription("VIPSubscribeOperation")
        operation.queue() { op in
            XCTAssertNil(operation.error)
            XCTAssertTrue(VCurrentUser.isVIPSubscriber?.boolValue)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(expectationThreshold, handler: nil)
    }
    
    func testSubscribeError() {
        let operation = VIPSubscribeOperation(productIdentifier: "")
        let expectedError = NSError(domain: "", code: -99, userInfo:nil)
        operation.purchaseManager = MockPurchaseManager(error: expectedError)
        
        let expectation = expectationWithDescription("VIPSubscribeOperation")
        operation.queue() { op in
            XCTAssertEqual(operation.error, expectedError)
            guard let isVIPSubscriber = VCurrentUser.isVIPSubscriber?.boolValue else {
                XCTFail()
                return
            }
            XCTAssertFalse(isVIPSubscriber.boolValue)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(expectationThreshold, handler: nil)
    }
    
    func testRestoreSuccess() {
        let operation = RestorePurchasesOperation()
        operation.purchaseManager = MockPurchaseManager()
        
        let expectation = expectationWithDescription("RestorePurchasesOperation")
        operation.queue() { op in
            XCTAssertNil(operation.error)
            XCTAssert(VCurrentUser.isVIPSubscriber.boolValue)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(expectationThreshold, handler: nil)
    }
    
    func testRestoreError() {
        let operation = RestorePurchasesOperation()
        let expectedError = NSError(domain: "", code: -99, userInfo:nil)
        operation.purchaseManager = MockPurchaseManager(error: expectedError)
        
        let expectation = expectationWithDescription("RestorePurchasesOperation")
        operation.queue() { op in
            XCTAssertEqual(operation.error, expectedError)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(expectationThreshold, handler: nil)
    }
}
