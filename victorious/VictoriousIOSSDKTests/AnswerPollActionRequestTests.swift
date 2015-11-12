//
//  AnswerPollActionRequestTests.swift
//  victorious
//
//  Created by Tian Lan on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK

class AnswerPollActionRequestTests: XCTestCase {
    
    func testSelectingFirstAnswerRequest() {
        let mockAnswerID: Int64 = 101
        let mockSequenceID: Int64 = 102
        
        let answerPollRequest = AnswerPollActionRequest(answerID: mockAnswerID, sequenceID: mockSequenceID)
        let urlRequest = answerPollRequest.urlRequest
        
        XCTAssertEqual(urlRequest.URL?.absoluteString, "/api/pollresult/create")
        
        guard let bodyData = urlRequest.HTTPBody else {
            XCTFail("No HTTP Body!")
            return
        }
        let bodyString = String(data: bodyData, encoding: NSUTF8StringEncoding)!
        
        XCTAssertNotNil(bodyString.rangeOfString("answer_id=\(mockAnswerID)"))
        XCTAssertNotNil(bodyString.rangeOfString("sequence_id=\(mockSequenceID)"))
    }
}
