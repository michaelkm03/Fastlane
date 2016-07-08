//
//  CreatorListRemoteOperationTests.swift
//  victorious
//
//  Created by Tian Lan on 4/25/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious
@testable import VictoriousIOSSDK

class CreatorListRemoteOperationTests: BaseFetcherOperationTestCase {
    
    func testResults() {
        let userID = 20160445
        let user = User(id: userID)
        testRequestExecutor = TestRequestExecutor(result: [user])
        
        let operation = CreatorListRemoteOperation(urlString: "http://google.com")
        operation.requestExecutor = testRequestExecutor
        
        operation.main()
        
        XCTAssertNil(operation.results)

        guard let persistentUsers: [VUser] = testStore.mainContext.v_findObjects(["remoteId": userID]) else {
            XCTFail("Unable to fetch the persistent user for CreatorListRemoteOperationTests")
            return
        }
        
        XCTAssertEqual(persistentUsers.count, 1)
        XCTAssertEqual(persistentUsers.first?.remoteId, userID)
    }
}
