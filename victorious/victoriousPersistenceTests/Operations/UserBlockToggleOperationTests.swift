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
        let user = User(id: currentUserID)
        VCurrentUser.update(to: user)
    }
    
    func testInitiallyBlocked() {
        let user = User(id: remoteUserID)
        user.block()
        
        let expectation = expectationWithDescription("UserBlockToggleOperation")
        
        let operation = UserBlockToggleOperation(
            user: user,
            blockAPIPath: APIPath(templatePath: ""),
            unblockAPIPath: APIPath(templatePath: "")
        )
        
        operation.queue { results, error, cancelled in
            XCTAssertFalse(user.isBlocked)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(expectationThreshold, handler: nil)
    }
    
    func testInitiallyUnblocked() {
        let user = User(id: remoteUserID)
        user.unblock()
        
        let expectation = expectationWithDescription("UserBlockToggleOperation")
        
        let operation = UserBlockToggleOperation(
            user: user,
            blockAPIPath: APIPath(templatePath: ""),
            unblockAPIPath: APIPath(templatePath: "")
        )
        
        operation.queue { results, error, cancelled in
            XCTAssertTrue(user.isBlocked)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(expectationThreshold, handler: nil)
    }
}
