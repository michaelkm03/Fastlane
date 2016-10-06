//
//  FanLoyaltyTests.swift
//  victorious
//
//  Created by Tian Lan on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import VictoriousIOSSDK
import XCTest

class FanLoyaltyTests: XCTestCase {
    func testJSONParsing() {
        guard let mockUserDataURL = Bundle(for: type(of: self)).url(forResource: "FanLoyalty", withExtension: "json"),
            let mockData = try? Data(contentsOf: mockUserDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        let fanLoyalty = FanLoyalty(json: JSON(data: mockData))
        
        XCTAssertEqual(fanLoyalty.points, Int(2764))
        XCTAssertEqual(fanLoyalty.level, 7)
        XCTAssertEqual(fanLoyalty.progress, 24)
        XCTAssertEqual(fanLoyalty.tier, "Cool Dude")
        XCTAssertEqual(fanLoyalty.achievementsUnlocked.count, 5)
        XCTAssertEqual(fanLoyalty.achievementsUnlocked.first, "receive_like_10")
        XCTAssertEqual(fanLoyalty.achievementsUnlocked.last, "any_post_1")
    }
}
