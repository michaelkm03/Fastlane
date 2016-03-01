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
    var objectUserSequences = [VSequence]()
    
    override func setUp() {
        super.setUp()
        
        objectUser = persistentStoreHelper.createUser(remoteId: 1)
        currentUser = persistentStoreHelper.createUser(remoteId: 2)
        
        for index in 0..<5 {
            let sequence = persistentStoreHelper.createSequence(remoteId: index)
            sequence.user = objectUser
            objectUserSequences.append(sequence)
        }
        
        currentUser.setAsCurrentUser()
        objectUser.isFollowedByMainUser = true
        objectUser.numberOfFollowers = 1
        currentUser.numberOfFollowing = 1
        
        let uniqueElements = [ "subjectUser" : currentUser, "objectUser" : objectUser ]
        let followedUser: VFollowedUser = testStore.mainContext.v_findOrCreateObject( uniqueElements )
        followedUser.objectUser = objectUser
        followedUser.subjectUser = currentUser
        followedUser.displayOrder = -1
        testStore.mainContext.v_save()
        
        operation = BlockUserOperation(userID: objectUser.remoteId.integerValue)
        operation.trackingManager = testTrackingManager
    }

    func testBlockingUser() {
        
        let context = testStore.mainContext
        var sequences = context.v_findObjectsWithEntityName(VSequence.v_entityName(), queryDictionary: ["user.remoteId" : objectUser.remoteId.integerValue])
        
        XCTAssertFalse(objectUser.isBlockedByMainUser.boolValue)
        XCTAssertNotEqual(objectUserSequences.count, 0)
        
        operation.main()
        
        sequences = context.v_findObjectsWithEntityName(VSequence.v_entityName(), queryDictionary: ["user.remoteId" : objectUser.remoteId.integerValue])
        
        XCTAssertTrue(objectUser.isBlockedByMainUser.boolValue)
        XCTAssertEqual(sequences.count, 0)
        
        XCTAssertEqual(1, testTrackingManager.trackEventCalls.count)
        XCTAssertEqual(VTrackingEventUserDidBlockUser, testTrackingManager.trackEventCalls.first?.eventName)
    }
    
}
