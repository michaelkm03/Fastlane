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
        operation.persistentStore = testStore
        
        let user = User(userID: testUserID)
        testRequestExecutor = TestRequestExecutor(result: [user])
        operation.requestExecutor = testRequestExecutor
        
        let expectation = expectationWithDescription("FriendFindBySocialNetworkFinished")
        
        operation.queue() { results, error, cancelled in
            expectation.fulfill()
            
            XCTAssertNil(error)
            guard let firstResult = results?.first as? VUser,
                let remoteId = firstResult.remoteId?.integerValue else {
                    XCTFail("First result should have a remoteId")
                    return
            }
            XCTAssertEqual(remoteId, self.testUserID)
        }
        
        waitForExpectationsWithTimeout(expectationThreshold, handler:nil)
    }
}
