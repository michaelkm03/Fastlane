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

class TrendingUsersOperationTests: BaseFetcherOperationTestCase {

    var operation: TrendingUsersOperation!

    func testResults() {
        let userID = 20160118
        let user = User(userID: userID)
        testRequestExecutor = TestRequestExecutor(result:[user])
        operation = TrendingUsersOperation()
        operation.requestExecutor = testRequestExecutor
        
        let expectation = expectationWithDescription("TrendingUsersOperation")
        operation.queue() { results, error, cancelled in
            XCTAssertNil(error)
            XCTAssertEqual(results?.count, 1)
            XCTAssertEqual(1, self.testRequestExecutor.executeRequestCallCount)
            
            guard let loadedUser = results?.first as? VUser else {
                XCTFail("first object in results should be an instance of VUser")
                return
            }
            
            XCTAssertEqual(loadedUser.remoteId, userID)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(expectationThreshold, handler: nil)
    }
}
