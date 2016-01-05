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

class SuggestedUsersOperationTests: XCTestCase {
    let expectationThreshold: Double = 10
    var operation: SuggestedUsersOperation!
    var testStore: TestPersistentStore!
    var testRequestExecutor: TestRequestExecutor!
    let operationHelper = RequestOperationTestHelper()

    override func setUp() {
        super.setUp()
        testStore = TestPersistentStore()
        operation = SuggestedUsersOperation()
        testRequestExecutor = TestRequestExecutor()
        operation.persistentStore = testStore
        operation.requestExecutor = testRequestExecutor
    }

    func testGetSuggestedUsers() {
        operation.main()
        XCTAssertEqual(1, self.testRequestExecutor.executeRequestCallCount)
    }
}
