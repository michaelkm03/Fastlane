//
//  FriendFindByEmailOperationTests.swift
//  victorious
//
//  Created by Michael Sena on 1/5/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious
@testable import VictoriousIOSSDK

class FriendFindByEmailOperationTests: BaseRequestOperationTestCase {

    let testUserID: Int = 1
    var operation: FriendFindByEmailOperation!
    let emails = ["h@h.hh", "mike@msena.com"]

    override func setUp() {
        super.setUp()

        operation = FriendFindByEmailOperation(emails:emails)
        operation.persistentStore = testStore
    }
    
    func testResults() {
        
        let expectation = expectationWithDescription("FriendFindByOnComplete")

        let user = User(userID: self.testUserID)
        self.operation.onComplete([user]) {
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(expectationThreshold) { error in
            guard let results = self.operation.results,
                let firstResult = results.first as? VUser else {
                XCTFail("We should have results here")
                return
            }
            XCTAssertEqual(firstResult.remoteId.integerValue, self.testUserID)
        }
    }

}
