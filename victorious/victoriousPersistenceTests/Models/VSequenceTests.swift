//
//  VSequenceTests.swift
//  victorious
//
//  Created by Alex Tamoykin on 1/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import VictoriousIOSSDK
@testable import victorious

class VSequenceTests: BasePersistentStoreTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testValid() {
        guard let sequenceModel: Sequence = createAdSequenceFromJSON(fileName: "SequenceWithAdBreak") else {
            XCTFail("Failed to create a sequence model")
            return
        }
        let persistentSequenceModel: VSequence = persistentStoreHelper.createSequence(remoteId: 1)
        persistentSequenceModel.populate(fromSourceModel: sequenceModel)
        XCTAssertNotNil(persistentSequenceModel.adBreak)
        XCTAssertEqual(persistentSequenceModel.voteResults?.count, 5)
    }

    private func createAdSequenceFromJSON(fileName fileName: String) -> Sequence? {
        guard let url = NSBundle(forClass: self.dynamicType).URLForResource(fileName, withExtension: "json") else {
            XCTFail("Failed to find mock data with name \(fileName).json")
            return nil
        }

        guard let Sequence = Sequence(url: url) else {
            return nil
        }

        return Sequence
    }
}
