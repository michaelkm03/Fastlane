//
//  UnblockUserOperationTests.swift
//  victorious
//
//  Created by Sharif Ahmed on 2/29/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious
@testable import VictoriousIOSSDK

class UnblockUserOperationTests: BaseFetcherOperationTestCase {
    var operation: UnblockUserOperation!
    var currentUser: VUser!
    var objectUser: VUser!
    
    override func setUp() {
        super.setUp()
        
        objectUser = persistentStoreHelper.createUser(remoteId: 1)
        currentUser = persistentStoreHelper.createUser(remoteId: 2)
        
        currentUser.setAsCurrentUser()
        objectUser.isBlockedByMainUser = NSNumber(bool: true)
        testStore.mainContext.v_save()
        
        operation = UnblockUserOperation(userID: objectUser.remoteId.integerValue)
        operation.trackingManager = testTrackingManager
    }
    
    func testUnblockingUser() {
        
        XCTAssertTrue(objectUser.isBlockedByMainUser.boolValue)
        
        operation.main()
        
        XCTAssertFalse(objectUser.isBlockedByMainUser.boolValue)
        
        XCTAssertEqual(1, testTrackingManager.trackEventCalls.count)
        XCTAssertEqual(VTrackingEventUserDidUnblockUser, testTrackingManager.trackEventCalls.first?.eventName)
        
        operation.main()
        
        XCTAssertEqual(2, testTrackingManager.trackEventCalls.count)
        XCTAssertEqual(VTrackingEventUnblockUserDidFail, testTrackingManager.trackEventCalls.last?.eventName)
    }
}
