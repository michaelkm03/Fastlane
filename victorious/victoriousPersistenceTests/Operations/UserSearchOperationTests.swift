//
//  UserSearchOperationTests.swift
//  victorious
//
//  Created by Michael Sena on 1/6/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious
@testable import VictoriousIOSSDK

class UserSearchOperationTests: XCTestCase {
    let expectationThreshold: Double = 10
    let testUserID: Int = 1
    var testStore: TestPersistentStore!
    var testTrackingManager: TestTrackingManager!
    var testRequestExecutor: TestRequestExecutor<UserSearchRequest>!
    var operation: UserSearchOperation!
    
    override func setUp() {
        super.setUp()
        testStore = TestPersistentStore()
        testTrackingManager = TestTrackingManager()
        testRequestExecutor = TestRequestExecutor()
        operation = UserSearchOperation(queryString: "test")
        operation.requestExecutor = testRequestExecutor
    }

    func testBasicSearch() {
        XCTAssertNotNil(operation)

        queueExpectedOperation(operation: operation)

        waitForExpectationsWithTimeout(expectationThreshold) { error in
            XCTAssertEqual(1, self.testRequestExecutor.executeRequestCallCount)
        }
    }

    func testReturnsResultsObjects() {    
        let user = User(userID: testUserID)
        operation.onComplete([user]) { () -> () in
        }
        
        guard let results = operation.results else {
            XCTFail("results should be set by now")
            return
        }
        XCTAssertEqual(1, results.count)
        if let firstResultsObject = results.first as? UserSearchResultObject {
            let sourceResult = firstResultsObject.sourceResult
            XCTAssertEqual(sourceResult.userID, testUserID)
        } else {
            XCTFail("should have at least one results object")
        }
    }

    private func queueExpectedOperation(operation operation: UserSearchOperation) -> XCTestExpectation {
        let expectation = expectationWithDescription("operation completed")
        operation.queue() { error in
            expectation.fulfill()
        }
        return expectation
    }

}
