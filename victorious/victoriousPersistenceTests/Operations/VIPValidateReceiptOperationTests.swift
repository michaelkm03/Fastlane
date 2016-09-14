//
//  VIPValidateSuscriptionOperationTests.swift
//  victorious
//
//  Created by Patrick Lynch on 3/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class VIPValidateSuscriptionOperationTests: XCTestCase {
    
    var operation: VIPValidateSuscriptionOperation!
    
    override func setUp() {
        super.setUp()
    }
    
    func testSuccess() {
        operation = VIPValidateSuscriptionOperation()
        testRequestExecutor = TestRequestExecutor()
        operation.requestExecutor = testRequestExecutor
        operation.receiptDataSource = MockReceiptDataSource(data: "9asf8dh708f7adsm".data() )
        
        let expectation = expectationWithDescription("VIPSubscribeOperation")
        operation.queue() { results, error in
            XCTAssertNil(error)
            XCTAssertEqual( self.testRequestExecutor.executeRequestCallCount, 1)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func testInitializtionFailure() {
        operation = VIPValidateSuscriptionOperation()
        testRequestExecutor = TestRequestExecutor()
        operation.requestExecutor = TestRequestExecutor()
        operation.receiptDataSource = MockReceiptDataSource(data: nil)
        
        let expectation = expectationWithDescription("VIPSubscribeOperation")
        operation.queue() { results, error in
            XCTAssertNotNil(error)
            XCTAssertEqual( self.testRequestExecutor.executeRequestCallCount, 0)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
}

private struct MockReceiptDataSource: ReceiptDataSource {
    
    var data: NSData?
    
    init(data: NSData?) {
        self.data = data
    }
    
    // MARK: - ReceiptDataSource
    
    func readReceiptData() -> NSData? {
        return self.data
    }
}
