//
//  UserBlockToggleOperationTests.swift
//  victorious
//
//  Created by Vincent Ho on 6/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class UserBlockToggleOperationTests: BaseFetcherOperationTestCase {
    let remoteUserID = 12345
    let currentUserID = 54321
    
    override func setUp() {
        super.setUp()
        let user = persistentStoreHelper.createUser(remoteId: currentUserID)
        user.setAsCurrentUser()
    }
    
    func testInitiallyFollowed() {
        let user: VUser = persistentStoreHelper.createUser(remoteId: remoteUserID)
        user.isBlockedByMainUser = true
        XCTAssertTrue(user.isBlockedByCurrentUser == true)
        
        let expectation = expectationWithDescription("UserBlockToggleOperation")
        
        let operation = UserBlockToggleOperation(
            userID: user.id,
            blockAPIPath: APIPath(templatePath: ""),
            unblockAPIPath: APIPath(templatePath: "")
        )
        
        operation.queue { results, error, cancelled in
            XCTAssertFalse(user.isBlockedByCurrentUser == true)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(expectationThreshold, handler: nil)
    }
    
    func testInitiallyUnupvoted() {
        let user: VUser = persistentStoreHelper.createUser(remoteId: remoteUserID)
        user.isBlockedByMainUser = false
        XCTAssertFalse(user.isBlockedByCurrentUser == true)
        
        let expectation = expectationWithDescription("UserBlockToggleOperation")
        
        let operation = UserBlockToggleOperation(
            userID: user.id,
            blockAPIPath: APIPath(templatePath: ""),
            unblockAPIPath: APIPath(templatePath: "")
        )
        
        operation.queue { results, error, cancelled in
            XCTAssertTrue(user.isBlockedByCurrentUser == true)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(expectationThreshold, handler: nil)
    }
}
