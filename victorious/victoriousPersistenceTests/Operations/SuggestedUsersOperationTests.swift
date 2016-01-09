//
//  SuggestedUsersOperationTests.swift
//  victorious
//
//  Created by Tian Lan on 11/24/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK
import SwiftyJSON
@testable import victorious

class SuggestedUsersOperationTests: BaseRequestOperationTestCase {
    
    let expectationThreshold: Double = 1
    let operationHelper = RequestOperationTestHelper()
    var operation: SuggestedUsersOperation!

    override func setUp() {
        super.setUp()
        
        operation = SuggestedUsersOperation()
        operation.persistentStore = testStore
        operation.requestExecutor = testRequestExecutor
    }

    func testGetSuggestedUsers() {
        operation.main()
        
        XCTAssertEqual(1, self.testRequestExecutor.executeRequestCallCount)
    }
}
