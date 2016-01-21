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

class UserSearchOperationTests: BaseRequestOperationTestCase {

    let testUserID: Int = 1

    func testBasicSearch() {
        guard let operation = UserSearchOperation(searchTerm: "test") else {
            XCTFail("Operation initialization should not fail here")
            return
        }
        operation.requestExecutor = testRequestExecutor

        queueExpectedOperation(operation: operation)

        waitForExpectationsWithTimeout(expectationThreshold) { error in
            XCTAssertEqual(1, self.testRequestExecutor.executeRequestCallCount)
        }
    }

    func testInitializationFail() {
        let str = String(bytes: [0xD8, 0x00] as [UInt8], encoding: NSUTF16BigEndianStringEncoding)!
        
        let operation = UserSearchOperation(searchTerm: str)
        XCTAssertNil(operation)
    }

    func testReturnsResultsObjects() {
        guard let operation = UserSearchOperation(searchTerm: "test") else {
            XCTFail("Operation initialization should not fail here")
            return
        }
        operation.requestExecutor = testRequestExecutor

        let user = User(userID: testUserID)
        operation.onComplete([user]) { }
        
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
}
