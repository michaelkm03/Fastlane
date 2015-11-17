//
//  FollowCountTests.swift
//  victorious
//
//  Created by Tian Lan on 11/16/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK
import SwiftyJSON

class FollowCountTests: XCTestCase {
    
    func testValid() {
        let mockFollowersCount = 101
        let mockFollowingCount = 102
        let validJSON = JSON(["subscribed_to": mockFollowingCount, "followers": mockFollowersCount])
        
        guard let followCount = FollowCount(json: validJSON) else {
            XCTFail("Initialization failed")
            return
        }
        
        XCTAssertEqual(followCount.followingCount, Int64(mockFollowingCount))
        XCTAssertEqual(followCount.followersCount, Int64(mockFollowersCount))
    }
    
    func testInvalid() {
        let invalidJSONArray = [
            JSON(["subscribed_to": false, "followers": 101]),
            JSON(["subscribed_to": 102, "followers": "Nonsense count"]),
            JSON(["subscribed_to": 103]),
            JSON(["followers": 104]),
            JSON([])
        ]
        
        for invalidJSON in invalidJSONArray {
            XCTAssertNil(FollowCount(json: invalidJSON))
        }
    }
}
