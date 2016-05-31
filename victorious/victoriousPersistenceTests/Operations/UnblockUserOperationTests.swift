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
    }
    
    func testUnblockingUser() {
        
        XCTAssertTrue(objectUser.isBlockedByMainUser?.boolValue == true)
        
        operation.main()
        
        XCTAssertFalse(objectUser.isBlockedByMainUser?.boolValue == true)
    }
}
