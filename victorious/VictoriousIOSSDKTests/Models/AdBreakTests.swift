//
//  AdBreakTests.swift
//  victorious
//
//  Created by Alex Tamoykin on 1/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import VictoriousIOSSDK

class AdBreakTests: XCTestCase {
    let sequenceHelper = SequenceHelper()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testValid() {
        guard let sequence = sequenceHelper.parseSequenceFromJSON(fileName: "SequenceWithAdBreaks"), let adBreaks = sequence.adBreaks else {
            XCTFail("Dude, I can't tests adBreaks without having adBreaks")
            return
        }

        XCTAssertEqual(1, adBreaks.count)
    }
}
