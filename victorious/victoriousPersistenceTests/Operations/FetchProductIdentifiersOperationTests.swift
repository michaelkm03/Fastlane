//
//  FetchTemplateProductIdentifiersOperationTests.swift
//  victorious
//
//  Created by Patrick Lynch on 3/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class FetchTemplateProductIdentifiersOperationTests: BaseFetcherOperationTestCase {
    
    var operation: FetchTemplateProductIdentifiersOperation!
    private var productsDataSource = MockProductsDataSource()
    
    func testSuccess() {
        let operation = FetchTemplateProductIdentifiersOperation(productsDataSource: productsDataSource)
        operation.purchaseManager = MockPurchaseManager()
        
        let expectation = expectationWithDescription("FetchTemplateProductIdentifiersOperation")
        operation.queue() { op in
            XCTAssertNil(operation.error)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(expectationThreshold, handler: nil)
    }
    
    func testError() {
        let operation = FetchTemplateProductIdentifiersOperation(productsDataSource: productsDataSource)
        let expectedError = NSError(domain: "", code: -99, userInfo:nil)
        operation.purchaseManager = MockPurchaseManager(error: expectedError)
        
        let expectation = expectationWithDescription("FetchTemplateProductIdentifiersOperation")
        operation.queue() { op in
            XCTAssertEqual(operation.error, expectedError)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(expectationThreshold, handler: nil)
    }
}

class MockProductsDataSource: NSObject, TemplateProductsDataSource {
    
    var vipSubscription: Subscription? {
        return Subscription(productIdentifier: "test_vip_subscription")
    }
    
    var productIdentifiersForVoteTypes: [String] {
        return [ "test_votetpye_product_0", "test_votetpye_product_1" ]
    }
    
    func voteTypeForProductIdentifier(productIdentifier: String) -> VVoteType? {
        abort()
    }
    
    var voteTypes: [VVoteType] {
        abort()
    }
}
