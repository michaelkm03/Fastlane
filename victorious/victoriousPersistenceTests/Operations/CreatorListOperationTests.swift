//
//  CreatorListOperationTests.swift
//  victorious
//
//  Created by Tian Lan on 4/25/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious
@testable import VictoriousIOSSDK

class CreatorListOperationTests: BaseFetcherOperationTestCase {
    let userID = 20160425
    
    func testResults() {
        let user = persistentStoreHelper.createUser(remoteId: userID)
        user.isCreator = NSNumber(bool: true)
        
        let operation = CreatorListOperation()
        operation.persistentStore = testStore
        operation.persistentStore.mainContext.v_save()
        
        operation.main()
        
        XCTAssertEqual(operation.results?.count, 1)
        XCTAssertEqual((operation.results?.first as! VUser).remoteId, userID)
    }
}
