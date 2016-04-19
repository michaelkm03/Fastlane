//
//  CreateChatServiceTokenOperationTests.swift
//  victorious
//
//  Created by Sebastian Nystorm on 8/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class CreateChatServiceTokenOperationTests: BaseFetcherOperationTestCase {

    private var operation: CreateChatServiceTokenOperation!
    private let workingUrlString = "https://vapi-dev.getvictorious.com/v1/users/%%USER_ID%%/chat/token"
    private let userId = 666
    private let token = "585f558c-de71-435f-85ec-6ef29e6f2641"
    
    func testInitialization() {
        operation = CreateChatServiceTokenOperation(expandableURLString: workingUrlString, currentUserID: userId)
        XCTAssertNotNil(operation.request, "Expected that a request object be created with the operation.")
    }
    
    func testOnComplete() {
        operation = CreateChatServiceTokenOperation(expandableURLString: workingUrlString, currentUserID: userId)
        testRequestExecutor = TestRequestExecutor(result: token)
        operation.requestExecutor = testRequestExecutor!
        
        let expectation = expectationWithDescription("TokenOperation")
        operation.queue() { results, error, canceled in
            XCTAssertNil(error)
            XCTAssertEqual(results!.count, 1)
            XCTAssertEqual(results!.first as? String, self.token)
            XCTAssertEqual(self.testRequestExecutor!.executeRequestCallCount, 1)
            XCTAssert(NSThread.isMainThread())
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(expectationThreshold, handler: nil)
    }
}
