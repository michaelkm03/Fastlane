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

class FollowCountOperationTests: BaseFetcherOperationTestCase {
    let userID = 6578
    var operation: FollowCountOperation!
    
    override func setUp() {
        super.setUp()
        
        operation = FollowCountOperation( userID: userID )
    }
    
    func testLoadCounts() {
        persistentStoreHelper.createUser(remoteId: userID)
        
        guard let user: VUser = testStore.mainContext.v_findObjects(["remoteId" : userID]).first else {
            XCTFail("No user to follow found after following a user")
            return
        }
        
        let followCount = FollowCount(followingCount: 87, followersCount:32)
        testRequestExecutor = TestRequestExecutor(result:followCount)
        operation.requestExecutor = testRequestExecutor
        
        let expectation = expectationWithDescription("FollowCountOperation")
        operation.queue() { (results, error) in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(1, handler: nil)
        
        XCTAssertEqual(followCount.followingCount, user.numberOfFollowing?.integerValue)
        XCTAssertEqual(followCount.followersCount, user.numberOfFollowers?.integerValue)
    }
    
    func testMissingUser() {
        let followCount = FollowCount(followingCount: 87, followersCount:32)
        testRequestExecutor = TestRequestExecutor(result:followCount)
        operation.requestExecutor = testRequestExecutor
        
        let expectation = expectationWithDescription("FollowCountOperation")
        operation.queue() { (results, error) in
            // As long as this completion block is called without crashing
            // from within the operation, this "missing user" case is covered
            XCTAssertNil(error)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(1, handler: nil)
    }
}
