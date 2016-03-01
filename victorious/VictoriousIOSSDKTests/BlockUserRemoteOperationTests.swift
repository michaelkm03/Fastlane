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
        
        currentUser.setAsCurrentUser()
        
        testStore.mainContext.v_save()
        
        operation = BlockUserRemoteOperation(userID: objectUser.remoteId.integerValue)
        operation.trackingManager = testTrackingManager
        operation.requestExecutor = testRequestExecutor
    }

    func testRemoteOperationTracking() {
        
        operation.main()
        
        XCTAssertEqual(1, testTrackingManager.trackEventCalls.count)
        XCTAssertEqual(VTrackingEventUserDidBlockUser, testTrackingManager.trackEventCalls.first?.eventName)
        
        operation.main()
        
        XCTAssertEqual(2, testTrackingManager.trackEventCalls.count)
        XCTAssertEqual(VTrackingEventBlockUserDidFail, testTrackingManager.trackEventCalls.last?.eventName)
    }
}
