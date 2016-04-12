//
//  BlockUserRemoteOperationTests.swift
//  victorious
//
//  Created by Sharif Ahmed on 2/29/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious
@testable import VictoriousIOSSDK

class BlockUserRemoteOperationTests: BaseFetcherOperationTestCase {
    
    var operation: BlockUserRemoteOperation!
    var currentUser: VUser!
    var objectUser: VUser!
    
    override func setUp() {
        super.setUp()
        
        objectUser = persistentStoreHelper.createUser(remoteId: 1)
        currentUser = persistentStoreHelper.createUser(remoteId: 2)
        
        operation = BlockUserRemoteOperation(userID: objectUser.remoteId.integerValue)
        operation.trackingManager = testTrackingManager
        
        currentUser.setAsCurrentUser()
        
        testStore.mainContext.v_save()
    }
    
    func testTrackingSuccess() {
        
        let expectation = expectationWithDescription("BlockUserRemoteOperation")
        
        operation.requestExecutor = TestRequestExecutor()
        operation.queue() { results, error, cancelled in
            
            XCTAssertEqual(1, self.testTrackingManager.trackEventCalls.count)
            XCTAssertEqual(VTrackingEventUserDidBlockUser, self.testTrackingManager.trackEventCalls.first?.eventName)
            
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(expectationThreshold, handler: nil)
    }
    
    func testTrackingFailure() {
        
        let expectation = expectationWithDescription("BlockUserRemoteOperation")
        let testError = NSError(domain: "", code:9809, userInfo:nil)
        
        operation.requestExecutor = TestRequestExecutor(error: testError)
        operation.queue() { results, error, cancelled in
            XCTAssertEqual(testError, error)
            
            XCTAssertEqual(1, self.testTrackingManager.trackEventCalls.count)
            XCTAssertEqual(VTrackingEventBlockUserDidFail, self.testTrackingManager.trackEventCalls.first?.eventName)
            
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(expectationThreshold, handler: nil)
    }
}
