//
//  FriendFindBySocialNetworkOperationTests.swift
//  victorious
//
//  Created by Tian Lan on 2/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK
@testable import victorious

class FriendFindBySocialNetworkOperationTests: BaseFetcherOperationTestCase {
    let testUserID = 1
    let facebookToken = "testFacebookToken"
    
    func testResults() {
        let operation = FriendFindBySocialNetworkOperation(token: facebookToken)
        let user = User(id: testUserID)
        testRequestExecutor = TestRequestExecutor(result: [user])
        operation.requestExecutor = testRequestExecutor
        
        let expectation = expectationWithDescription("FriendFindBySocialNetworkFinished")
        
        operation.queue() { results, error, cancelled in
            
            XCTAssertNil(error)
            guard let firstResult = results?.first as? VUser else {
                    XCTFail("First result should have a remoteId")
                    return
            }
            let remoteId = firstResult.remoteId.integerValue
            XCTAssertEqual(remoteId, self.testUserID)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(expectationThreshold, handler: nil)
    }
}
