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

class FriendFindBySocialNetworkOperationTests: BaseRequestOperationTestCase {
    let testUserID = 1
    let facebookToken = "testFacebookToken"
    
    func testResults() {
        let operation = FriendFindBySocialNetworkOperation(token: facebookToken)
        operation.persistentStore = testStore
        operation.requestExecutor = testRequestExecutor
        
        let expectation = expectationWithDescription("FriendFindBySocialNetworkFinished")
        
        let user = User(userID: testUserID)
        operation.onComplete([user]) {
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(expectationThreshold) { (results, error) in
            guard let results = operation.results,
                let firstResult = results.first as? VUser else {
                    XCTFail("We should have results here")
                    return
            }
            guard let remoteId = firstResult.remoteId?.integerValue else {
                XCTFail("First result should have a removeId")
                return
            }
            XCTAssertEqual(remoteId, self.testUserID)
        }
    }
}
