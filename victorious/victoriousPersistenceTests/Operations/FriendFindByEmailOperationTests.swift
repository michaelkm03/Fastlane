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

class FriendFindByEmailOperationTests: BaseFetcherOperationTestCase {
    
    let testUserID: Int = 1
    let emails = ["h@h.hh", "mike@msena.com"]
    
    func testResults() {
        guard let operation = FriendFindByEmailOperation(emails: emails) else {
            XCTFail("Operation initialization should not fail here")
            return
        }
        
        let expectation = expectationWithDescription("FriendFindByOnComplete")
        
        let user = User(userID: self.testUserID)
        operation.persistentStore = testStore
        operation.requestExecutor = TestRequestExecutor(result: [user])
        
        operation.queueOn(testQueue) { (results, error) in
            expectation.fulfill()
            
            guard let results = operation.results,
                let firstResult = results.first as? VUser else {
                    XCTFail("We should have results here")
                    return
            }
            
            guard let remoteId = firstResult.remoteId?.integerValue else {
                XCTFail("First result should have a remoteId")
                return
            }
            
            XCTAssertEqual(remoteId, self.testUserID)
        }
        
        waitForExpectationsWithTimeout(expectationThreshold, handler:nil)
    }
    
    func testError() {
        guard let operation = FriendFindByEmailOperation(emails: emails) else {
            XCTFail("Operation initialization should not fail here")
            return
        }
        
        let expectation = expectationWithDescription("FriendFindByOnComplete")
        
        let user = User(userID: self.testUserID)
        operation.persistentStore = testStore
        operation.requestExecutor = TestRequestExecutor(result: [user])
        
        operation.queueOn(testQueue) { (results, error) in
            expectation.fulfill()
            
            guard let results = operation.results,
                let firstResult = results.first as? VUser else {
                    XCTFail("We should have results here")
                    return
            }
            
            guard let remoteId = firstResult.remoteId?.integerValue else {
                XCTFail("First result should have a remoteId")
                return
            }
            
            XCTAssertEqual(remoteId, self.testUserID)
        }
        
        waitForExpectationsWithTimeout(expectationThreshold, handler:nil)
    }

    func testInitializationFail() {
        let operation = FriendFindByEmailOperation(emails: [])
        XCTAssertNil(operation)
    }
}
