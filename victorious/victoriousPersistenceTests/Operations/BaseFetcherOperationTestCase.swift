//
//  BaseFetcherOperationTestCase.swift
//  victorious
//
//  Created by Michael Sena on 1/5/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK
@testable import victorious

/// All test case classes that are testing `FetcherOperation` subclasses are
/// encouraged to subclass.  It provides some useful and code-saving utilities
/// that each test case needs to thoroughly test a `FetcherOperation` subclass
class BaseFetcherOperationTestCase: BasePersistentStoreTestCase {

    let expectationThreshold: Double = 1
    var testTrackingManager: TestTrackingManager!
    var testRequestExecutor: TestRequestExecutor!
    let testQueue = NSOperationQueue()

    override func setUp() {
        super.setUp()
        testTrackingManager = TestTrackingManager()
        testRequestExecutor = TestRequestExecutor()
    }
}
