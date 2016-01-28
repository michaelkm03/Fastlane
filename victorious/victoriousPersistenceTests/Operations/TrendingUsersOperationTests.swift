//
//  TrendingUsersOperationTests.swift
//  victorious
//
//  Created by Tian Lan on 1/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK
@testable import victorious

class TrendingUsersOperationTests: BaseRequestOperationTestCase {
    
    func testRequestExecution() {
        let operation = TrendingUsersOperation()
        operation.requestExecutor = testRequestExecutor
        
        queueExpectedOperation(operation: operation)

        waitForExpectationsWithTimeout(expectationThreshold) { error in
            XCTAssertEqual(1, self.testRequestExecutor.executeRequestCallCount)
        }
    }

    func testResults() {
        let userID = 20160118
        let user = User(userID: userID)
        
        let operation = TrendingUsersOperation()
        operation.persistentStore = testStore
        
        let expectation = expectationWithDescription("TrendingUsersOperationOnCopmlete")

        operation.onComplete([user]) {
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(expectationThreshold) { error in
            XCTAssertEqual(operation.results?.count, 1)
            
            guard let firstResult = operation.results?.first as? VUser else {
                XCTFail("first object in results should be an instance of HashtagSearchResultObject")
                return
            }
            
            XCTAssertEqual(firstResult.remoteId.integerValue, userID)
        }
    }
}
