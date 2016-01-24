//
//  VSequenceTests.swift
//  victorious
//
//  Created by Alex Tamoykin on 1/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK
@testable import VictoriousIOSSDKTests
@testable import victorious

class VSequenceTests: XCTestCase {
    let modelHelper = ModelHelper()
    var persistentStoreHelper: PersistentStoreTestHelper!
    var testStore: TestPersistentStore!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        testStore = TestPersistentStore()
        persistentStoreHelper = PersistentStoreTestHelper(persistentStore: testStore)
        persistentStoreHelper.tearDownPersistentStore()
    }

    func testValid() {
        guard let sequenceModel: Sequence = modelHelper.createModel(JSONFileName: "SequenceWithAdBreak") else {
            XCTFail("Failed to create a sequence model")
            return
        }
        let persistentSequenceModel: VSequence = persistentStoreHelper.createSequence(remoteId: 1)
        persistentSequenceModel.populate(fromSourceModel: sequenceModel)
        XCTAssertEqual(1, persistentSequenceModel.adBreaks?.count)
    }

    override func tearDown() {
        super.tearDown()
        persistentStoreHelper.tearDownPersistentStore()
    }
}
