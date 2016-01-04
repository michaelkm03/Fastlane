//
//  PollVoteRequestTests.swift
//  victorious
//
//  Created by Tian Lan on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK

class PollVoteRequestTests: XCTestCase {
    
    func testAnsweringActionRequest() {
        let mockAnswerID: Int64 = 101
        let mockSequenceID: String = "102"
        
        let pollVoteRequest = PollVoteRequest(sequenceID: mockSequenceID, answerID: mockAnswerID)
        let urlRequest = pollVoteRequest.urlRequest
        
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
