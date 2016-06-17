//
//  ContentUpvoteToggleOperationTests.swift
//  victorious
//
//  Created by Vincent Ho on 6/2/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class ContentUpvoteToggleOperationTests: BaseFetcherOperationTestCase {
    let contentID = "12345"
    let userRemoteID = 54321

    override func setUp() {
        super.setUp()
        let user = persistentStoreHelper.createUser(remoteId: userRemoteID)
        user.setAsCurrentUser()
    }
    
    func testInitiallyUpvoted() {
        let content: VContent = persistentStoreHelper.createContent(contentID, likedByCurrentUser: true)
        XCTAssertTrue(content.isLikedByCurrentUser)
        XCTAssertEqual(content.id, contentID)
        
        let expectation = expectationWithDescription("ContentUpvoteToggleOperation")
        
        let operation = ContentUpvoteToggleOperation(
            contentID: contentID,
            upvoteURL: "",
            unupvoteURL: ""
        )
        operation.queue { results, error, cancelled in
            XCTAssertFalse(content.isLikedByCurrentUser)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(expectationThreshold, handler: nil)
    }
    
    func testInitiallyUnupvoted() {
        let content: VContent = persistentStoreHelper.createContent(contentID)
        XCTAssertFalse(content.isLikedByCurrentUser)
        XCTAssertEqual(content.id, contentID)
        
        let expectation = expectationWithDescription("ContentUpvoteToggleOperation")
        
        let operation = ContentUpvoteToggleOperation(
            contentID: contentID,
            upvoteURL: "",
            unupvoteURL: ""
        )
        operation.queue { results, error, cancelled in
            XCTAssertTrue(content.isLikedByCurrentUser)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(expectationThreshold, handler: nil)
        
    }
}
