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
        let mockSequenceID = 102
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
        
        XCTAssertEqual( pollResult.sequenceID, Int64(mockSequenceID) )
        XCTAssertEqual( pollResult.answerID, Int64(mockAnswerID) )
        XCTAssertEqual( pollResult.totalCount, Int64(mockTotalCount) )
    }
    
    func testInvalid() {
        let invalidJSONArray = [
            JSON(["answer_id": false]),
            JSON(["answer_id": "Nonsense answer_id"]),
            JSON(["sequence_id": 104]),
            JSON([])
        ]
        
        for invalidJSON in invalidJSONArray {
            XCTAssertNil(PollResult(json: invalidJSON))
        }
    }
}
