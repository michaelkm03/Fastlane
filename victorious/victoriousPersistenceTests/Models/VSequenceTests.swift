//
//  VSequenceTests.swift
//  victorious
//
//  Created by Alex Tamoykin on 1/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import VictoriousIOSSDK
@testable import VictoriousIOSSDKTests
@testable import victorious

class VSequenceTests: BasePersistentStoreTestCase {
    let modelHelper = ModelHelper()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testValid() {
        guard let sequenceModel: Sequence = modelHelper.createModel(JSONFileName: "SequenceWithAdBreak") else {
            XCTFail("Failed to create a sequence model")
            return
        }
        let persistentSequenceModel: VSequence = persistentStoreHelper.createSequence(remoteId: 1)
        persistentSequenceModel.populate(fromSourceModel: sequenceModel)
        XCTAssert(persistentSequenceModel.adBreak != nil)
    }
}
