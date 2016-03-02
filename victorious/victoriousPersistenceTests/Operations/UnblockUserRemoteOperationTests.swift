//
//  UnblockUserRemoteOperationTests.swift
//  victorious
//
//  Created by Sharif Ahmed on 2/29/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious
@testable import VictoriousIOSSDK

class UnblockUserRemoteOperationTests: BaseFetcherOperationTestCase {
    
    var operation: UnblockUserRemoteOperation!
    var currentUser: VUser!
    var objectUser: VUser!
    
    override func setUp() {
        super.setUp()
        
        objectUser = persistentStoreHelper.createUser(remoteId: 1)
        currentUser = persistentStoreHelper.createUser(remoteId: 2)
        
        currentUser.setAsCurrentUser()
        
        testStore.mainContext.v_save()
        
        operation = UnblockUserRemoteOperation(userID: objectUser.remoteId.integerValue)
        operation.trackingManager = testTrackingManager
        operation.requestExecutor = testRequestExecutor
    }
    
    func testRemoteOperationTracking() {
        
        let expectation = expectationWithDescription("UnblockUserRemoteOperation")
        operation.queue() { (results, error) in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(expectationThreshold, handler:nil)
        
        XCTAssertEqual(1, testTrackingManager.trackEventCalls.count)
        XCTAssertEqual(VTrackingEventUserDidUnblockUser, testTrackingManager.trackEventCalls.first?.eventName)
    }
}
