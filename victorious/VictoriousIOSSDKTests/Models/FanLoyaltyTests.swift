//
//  FanLoyaltyTests.swift
//  victorious
//
//  Created by Tian Lan on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import SwiftyJSON
import VictoriousIOSSDK
import XCTest

class FanLoyaltyTests: XCTestCase {
    func testJSONParsing() {
        guard let mockUserDataURL = NSBundle(forClass: self.dynamicType).URLForResource("FanLoyalty", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockUserDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        guard let fanLoyalty = FanLoyalty(json: JSON(data: mockData)) else {
            XCTFail("Fan Loyalty initializer failed")
            return
        }
        
        XCTAssertEqual(fanLoyalty.points, Int64(2764))
        XCTAssertEqual(fanLoyalty.level, 7)
        XCTAssertEqual(fanLoyalty.progress, 24)
    }
}
