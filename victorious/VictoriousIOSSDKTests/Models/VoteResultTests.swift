//
//  VoteResultTests.swift
//  victorious
//
//  Created by Tian Lan on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK

class VoteResultTests: XCTestCase {
    
    func testValid() {
        let mockID = "101"
        let mockCount = 102
        let validJSON = JSON(["id": mockID, "count": mockCount])
        
        guard let voteResult = VoteResult(json: validJSON) else {
            XCTFail("Initialization failed")
            return
        }
        
        XCTAssertEqual(voteResult.voteID, mockID)
        XCTAssertEqual(voteResult.voteCount, mockCount)
    }
    
    func testInvalid() {
        let invalidJSONArray = [
            JSON(["id": false, "count": 101]),
            JSON(["id": 102, "count": "Nonsense count"]),
            JSON(["id": "103"]),
            JSON(["count": 104]),
            JSON([])
        ]
        
        for invalidJSON in invalidJSONArray {
            XCTAssertNil(VoteResult(json: invalidJSON))
        }
    }
}
