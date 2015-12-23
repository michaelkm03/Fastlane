//
//  FanLoyaltyTests.swift
//  victorious
//
//  Created by Josh Hinman on 12/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class FanLoyaltyTests: XCTestCase {

    func testInitByDictionary() {
        let fanLoyalty = FanLoyalty(dictionary: ["level": 5, "progress": 70])
        XCTAssertEqual(fanLoyalty?.level, 5)
        XCTAssertEqual(fanLoyalty?.progressPercentage, 70)
    }

}
