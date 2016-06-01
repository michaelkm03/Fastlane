//
//  TrendingUsersOperationTests.swift
//  victorious
//
//  Created by Tian Lan on 1/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK
@testable import victorious

class TrendingUsersOperationTests: BaseFetcherOperationTestCase {
    
    func testResults() {
        let userID = 20160118
        let user = User(id: userID)
        testRequestExecutor = TestRequestExecutor(result:[user])
        let operation = TrendingUsersOperation()
        operation.requestExecutor = testRequestExecutor
        
        operation.main()
        
        XCTAssertNil(operation.error)
        XCTAssertEqual(operation.results?.count, 1)
        XCTAssertEqual(1, self.testRequestExecutor.executeRequestCallCount)
        
        guard let loadedUser = operation.results?.first as? VUser else {
            XCTFail("first object in results should be an instance of VUser")
            return
        }
        
        XCTAssertEqual(loadedUser.remoteId, userID)
    }
}
