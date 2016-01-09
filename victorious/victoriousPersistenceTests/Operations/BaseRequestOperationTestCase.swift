//
//  BaseRequestOperationTestCase.swift
//  victorious
//
//  Created by Michael Sena on 1/5/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK
@testable import victorious

/// All test case classes that are testing `RequestOperation` subclasses are
/// encouraged to subclass.  It provides some useful and code-saving utilities
/// that each test case needs to thoroughly test a `RequestOperation` subclass
class BaseRequestOperationTestCase: XCTestCase {

    let expectationThreshold: Double = 1

    var testStore: TestPersistentStore!
    var testTrackingManager: TestTrackingManager!
    var testRequestExecutor: TestRequestExecutor!
    var persistentStoreHelper: PersistentStoreTestHelper!

    override func setUp() {
        super.setUp()
        testStore = TestPersistentStore()
        persistentStoreHelper = PersistentStoreTestHelper(persistentStore: testStore)
        testTrackingManager = TestTrackingManager()
        testRequestExecutor = TestRequestExecutor()
    }
    
    override func tearDown() {
        self.persistentStoreHelper.tearDownPersistentStore()
    }

    // Provides an XCTestExpectation that will be fulfilled in the operation's `completionBlock`.
    func queueExpectedOperation(operation operation: RequestOperation) -> XCTestExpectation {
        let expectation = expectationWithDescription("operation completed")
        operation.queue() { error in
            expectation.fulfill()
        }
        return expectation
    }
}
