//
//  PollAnswerTests.swift
//  victorious
//
//  Created by Tian Lan on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK
import SwiftyJSON

class PollAnswerTests: XCTestCase {
    
    func testValid() {
        let mockSequenceID = 101
        let mockAnswerID = 102
        let validJSON = JSON(["sequence_id": mockSequenceID, "answer_id": mockAnswerID])
        
        guard let pollAnswer = PollAnswer(json: validJSON) else {
            XCTFail("Initialization failed")
            return
        }
        
        XCTAssertEqual(pollAnswer.sequenceID, Int64(mockSequenceID))
        XCTAssertEqual(pollAnswer.answerID, Int64(mockAnswerID))
    }
    
    func testInvalid() {
        let invalidJSON = JSON(["sequence_id": false, "answer_id": "Not really an ID"])
        let anotherInvalidJSON = JSON([])
        
        XCTAssertNil(PollAnswer(json: invalidJSON))
        XCTAssertNil(PollAnswer(json: anotherInvalidJSON))
    }
}
