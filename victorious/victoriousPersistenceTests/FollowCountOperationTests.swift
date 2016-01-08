//
//  FollowCountOperationTests.swift
//  victorious
//
//  Created by Patrick Lynch on 1/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious
@testable import VictoriousIOSSDK

class FollowCountOperationTests: BaseRequestOperationTestCase {
    
    let userID = 6578
    let operationHelper = RequestOperationTestHelper()
    var operation: FollowCountOperation!
    
    override func setUp() {
        super.setUp()
        
        operation = FollowCountOperation( userID: userID)
        operation.requestExecutor = testRequestExecutor
    }
    
    func testLoadCounts() {
        operationHelper.createUser(remoteId: userID, persistentStore: testStore)
        
        guard let user: VUser = testStore.mainContext.v_findObjects(["remoteId" : userID]).first else {
            XCTFail("No user to follow found after following a user")
            return
        }
        
        let expectation = expectationWithDescription("operation completed")
        let followCount = FollowCount(followingCount: 87, followersCount:32)
        
        // TODO: Call `main()` instead and assert testRequestExecutor.executeRequestCallCount
        operation.onComplete(followCount) {
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(1, handler: nil)
        
        XCTAssertEqual(followCount.followingCount, user.numberOfFollowing.integerValue)
        XCTAssertEqual(followCount.followersCount, user.numberOfFollowers.integerValue)
    }
    
    func testMissingUser() {
        let expectation = expectationWithDescription("operation completed")
        let followCount = FollowCount(followingCount: 87, followersCount:32)
    
        // TODO: Call `main()` instead and assert testRequestExecutor.executeRequestCallCount
        operation.onComplete(followCount) {
            // As long as this completion block is called without crashing
            // from within the operation, this "missing user" case is covered
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(1, handler: nil)
    }
}
