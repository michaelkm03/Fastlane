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

class UserSearchOperationTests: BaseFetcherOperationTestCase {

    let testUserID: Int = 1
    var operation: UserSearchOperation!
    
    override func setUp() {
        super.setUp()
        operation = UserSearchOperation(searchTerm: "test")
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

        let user = User(id: testUserID)
        testRequestExecutor = TestRequestExecutor(result:[user])
        operation.requestExecutor = testRequestExecutor
        
        let expectation = expectationWithDescription("TrendingUsersOperation")
        operation.queue() { results, error, cancelled in
            
            guard let results = results else {
                XCTFail("results should be set by now")
                return
            }
            XCTAssertEqual(1, results.count)
            if let firstResultsObject = results.first as? UserSearchResultObject {
                let sourceResult = firstResultsObject.sourceResult
                XCTAssertEqual(sourceResult.id, self.testUserID)
            } else {
                XCTFail("should have at least one results object")
            }
            
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(expectationThreshold, handler: nil)
    }
}
