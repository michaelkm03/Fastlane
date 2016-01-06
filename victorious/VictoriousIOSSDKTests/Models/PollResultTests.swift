//
//  PollResultTests.swift
//  victorious
//
//  Created by Tian Lan on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK
import SwiftyJSON

class PollResultTests: XCTestCase {
    
    func testValid() {
        let mockAnswerID = 101
        let mockSequenceID = "102"
        let mockTotalCount = 103
        
        let validJSON = JSON([
            "answer_id": mockAnswerID,
            "sequence_id": mockSequenceID,
            "total_count": mockTotalCount]
        )
        
        guard let pollResult = PollResult(json: validJSON) else {
            XCTFail("Initialization failed")
            return
        }
        
        XCTAssertEqual( pollResult.sequenceID, mockSequenceID )
        XCTAssertEqual( pollResult.answerID, Int(mockAnswerID) )
        XCTAssertEqual( pollResult.totalCount, Int(mockTotalCount) )
    }
    
    func testInvalid() {
        let invalidJSONArray = [
            JSON(["unrelated": false]),
            JSON([]) // empty
        ]
        
        for invalidJSON in invalidJSONArray {
            XCTAssertNil(PollResult(json: invalidJSON))
        }
    }
}
