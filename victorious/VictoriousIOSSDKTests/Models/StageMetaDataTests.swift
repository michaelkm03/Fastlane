//
//  StageMetaDataTests.swift
//  victorious
//
//  Created by Sebastian Nystorm on 13/7/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import VictoriousIOSSDK

class StageMetaDataTests: XCTestCase {

    private let testTitle = "Teh Stage"

    func testInitialiation() {
        let metaData = StageMetaData(title: testTitle)
        XCTAssertEqual(metaData.title, testTitle)
    }
}
