//
//  VoteTests.swift
//  victorious
//
//  Created by Tian Lan on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK
import SwiftyJSON

class VoteTests: XCTestCase {
    
    func testValid() {
        let mockSequenceID = 101
        let mockAnswerID = 102
        let validJSON = JSON(["sequence_id": mockSequenceID, "answer_id": mockAnswerID])
        
        guard let vote = Vote(json: validJSON) else {
            XCTFail("Initialization failed")
            return
        }
        
        XCTAssertEqual(vote.sequenceID, Int64(mockSequenceID))
        XCTAssertEqual(vote.answerID, Int64(mockAnswerID))
    }
    
    func testInvalid() {
        let invalidJSON = JSON(["sequence_id": false, "answer_id": "Not really an ID"])
        let anotherInvalidJSON = JSON([])
        
        XCTAssertNil(Vote(json: invalidJSON))
        XCTAssertNil(Vote(json: anotherInvalidJSON))
    }
}
