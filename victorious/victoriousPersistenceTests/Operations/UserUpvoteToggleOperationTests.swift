//
//  UserUpvoteToggleOperationTests.swift
//  victorious
//
//  Created by Vincent Ho on 6/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class UserUpvoteToggleOperationTests: XCTestCase {
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
        
        let expectation = self.expectation(description: "UserUpvoteToggleOperation")
        
        let operation = UserUpvoteToggleOperation(
            user: user,
            upvoteAPIPath: APIPath(templatePath:"foo"),
            unupvoteAPIPath: APIPath(templatePath:"foo")
        )
        
        operation.queue { result in
            XCTAssertFalse(user.isUpvoted)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testInitiallyUnupvoted() {
        let user = User(id: remoteUserID)
        user.unUpvote()
        XCTAssertFalse(user.isRemotelyFollowedByCurrentUser == true)
        
        let expectation = self.expectation(description: "UserUpvoteToggleOperation")
        
        let operation = UserUpvoteToggleOperation(
            user: user,
            upvoteAPIPath: APIPath(templatePath:"foo"),
            unupvoteAPIPath: APIPath(templatePath:"foo")
        )
        
        operation.queue { result in
            XCTAssertTrue(user.isUpvoted)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
}
