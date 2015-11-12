//
//  VoteResultTests.swift
//  victorious
//
//  Created by Tian Lan on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK
import SwiftyJSON

class VoteResultTests: XCTestCase {
    
    func testValid() {
        let mockID = 101
        let mockCount = 102
        let validJSON = JSON(["id": mockID, "count": mockCount])
        
        guard let voteResult = VoteResult(json: validJSON) else {
            XCTFail("Initialization failed")
            return
        }
        
        XCTAssertEqual(voteResult.voteID, Int64(mockID))
        XCTAssertEqual(voteResult.voteCount, Int64(mockCount))
    }
    
    func testInvalid() {
        let invalidJSON = JSON(["id": false, "count": "A count that does not make sense"])
        let anotherInvalidJSON = JSON([])
        
        XCTAssertNil(VoteResult(json: invalidJSON))
        XCTAssertNil(VoteResult(json: anotherInvalidJSON))
    }
}
