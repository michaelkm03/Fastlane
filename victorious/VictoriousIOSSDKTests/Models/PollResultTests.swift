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
        let mockSequenceID = 101
        let mockAnswerID = 102
        let validJSON = JSON(["sequence_id": mockSequenceID, "answer_id": mockAnswerID])
        
        guard let pollAnswer = PollResult(json: validJSON) else {
            XCTFail("Initialization failed")
            return
        }
        
        XCTAssertEqual(pollAnswer.sequenceID, Int64(mockSequenceID))
        XCTAssertEqual(pollAnswer.answerID, Int64(mockAnswerID))
    }
    
    func testInvalid() {
        let invalidJSONArray = [
            JSON(["sequence_id": false, "answer_id": 101]),
            JSON(["sequence_id": 102, "answer_id": "Nonsense count"]),
            JSON(["sequence_id": 103]),
            JSON(["answer_id": 104]),
            JSON([])
        ]
        
        for invalidJSON in invalidJSONArray {
            XCTAssertNil(PollResult(json: invalidJSON))
        }
    }
}
