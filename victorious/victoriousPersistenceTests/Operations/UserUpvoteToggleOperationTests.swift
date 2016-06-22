//
//  UserUpvoteToggleOperationTests.swift
//  victorious
//
//  Created by Vincent Ho on 6/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class UserUpvoteToggleOperationTests: BaseFetcherOperationTestCase {
    let remoteUserID = 12345
    let currentUserID = 54321
    
    override func setUp() {
        super.setUp()
        let user = persistentStoreHelper.createUser(remoteId: currentUserID)
        user.setAsCurrentUser()
    }
    
    func testInitiallyFollowed() {
        let user: VUser = persistentStoreHelper.createUser(remoteId: remoteUserID)
        user.isFollowedByMainUser = true
        XCTAssertTrue(user.isFollowedByCurrentUser == true)
        
        let expectation = expectationWithDescription("UserUpvoteToggleOperation")
        
        let operation = UserUpvoteToggleOperation(
            userID: remoteUserID,
            upvoteAPIPath: APIPath(templatePath: ""),
            unupvoteAPIPath: APIPath(templatePath: "")
        )
        
        operation.queue { results, error, cancelled in
            XCTAssertFalse(user.isFollowedByCurrentUser == true)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(expectationThreshold, handler: nil)
    }
    
    func testInitiallyUnupvoted() {
        let user: VUser = persistentStoreHelper.createUser(remoteId: remoteUserID)
        user.isFollowedByMainUser = false
        XCTAssertFalse(user.isFollowedByCurrentUser == true)
        
        let expectation = expectationWithDescription("UserUpvoteToggleOperation")
        
        let operation = UserUpvoteToggleOperation(
            userID: remoteUserID,
            upvoteAPIPath: APIPath(templatePath: ""),
            unupvoteAPIPath: APIPath(templatePath: "")
        )
        
        operation.queue { results, error, cancelled in
            XCTAssertTrue(user.isFollowedByCurrentUser == true)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(expectationThreshold, handler: nil)
    }
}