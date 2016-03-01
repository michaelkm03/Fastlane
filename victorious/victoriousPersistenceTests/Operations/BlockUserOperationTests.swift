//
//  BlockUserOperationTests.swift
//  victorious
//
//  Created by Sharif Ahmed on 2/29/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious
@testable import VictoriousIOSSDK

class BlockUserOperationTests: BaseFetcherOperationTestCase {
    var operation: BlockUserOperation!
    var currentUser: VUser!
    var objectUser: VUser!
    
    override func setUp() {
        super.setUp()
        
        objectUser = persistentStoreHelper.createUser(remoteId: 1)
        currentUser = persistentStoreHelper.createUser(remoteId: 2)
        
        for index in 0..<5 {
            let sequence = persistentStoreHelper.createSequence(remoteId: index)
            sequence.user = objectUser
        }
        
        currentUser.setAsCurrentUser()
        
        testStore.mainContext.v_save()
        
        operation = BlockUserOperation(userID: objectUser.remoteId.integerValue)
        // operation.trackingManager = testTrackingManager
    }

    func testBlockingUser() {
        
        let context = testStore.mainContext
        var sequences = context.v_findObjectsWithEntityName(VSequence.v_entityName(), queryDictionary: ["user.remoteId" : objectUser.remoteId.integerValue])
        
        XCTAssertFalse(objectUser.isBlockedByMainUser.boolValue)
        XCTAssertNotEqual(sequences.count, 0)
        
        operation.main()
        
        sequences = context.v_findObjectsWithEntityName(VSequence.v_entityName(), queryDictionary: ["user.remoteId" : objectUser.remoteId.integerValue])
        
        XCTAssertTrue(objectUser.isBlockedByMainUser.boolValue)
        XCTAssertEqual(sequences.count, 0)
        
        XCTAssertEqual(1, testTrackingManager.trackEventCalls.count)
        XCTAssertEqual(VTrackingEventUserDidBlockUser, testTrackingManager.trackEventCalls.first?.eventName)
        
        operation.main()
        
        XCTAssertEqual(2, testTrackingManager.trackEventCalls.count)
        XCTAssertEqual(VTrackingEventBlockUserDidFail, testTrackingManager.trackEventCalls.last?.eventName)
    }
}
