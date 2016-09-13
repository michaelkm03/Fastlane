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
        let user = User(id: currentUserID)
        VCurrentUser.update(to: user)
    }
    
    func testInitiallyFollowed() {
        let user = User(id: remoteUserID)
        user.upvote()
        
        let expectation = expectationWithDescription("UserUpvoteToggleOperation")
        
        let operation = UserUpvoteToggleOperation(
            user: user,
            upvoteAPIPath: APIPath(templatePath: ""),
            unupvoteAPIPath: APIPath(templatePath: "")
        )
        
        operation.queue { result in
            XCTAssertFalse(user.isUpvoted)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(expectationThreshold, handler: nil)
    }
    
    func testInitiallyUnupvoted() {
        let user = User(id: remoteUserID)
        user.unUpvote()
        XCTAssertFalse(user.isRemotelyFollowedByCurrentUser == true)
        
        let expectation = expectationWithDescription("UserUpvoteToggleOperation")
        
        let operation = UserUpvoteToggleOperation(
            user: user,
            upvoteAPIPath: APIPath(templatePath: ""),
            unupvoteAPIPath: APIPath(templatePath: "")
        )
        
        operation.queue { result in
            XCTAssertTrue(user.isUpvoted)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(expectationThreshold, handler: nil)
    }
}
