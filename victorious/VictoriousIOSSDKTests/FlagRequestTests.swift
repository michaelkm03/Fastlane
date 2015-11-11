//
//  FlagRequestTests.swift
//  victorious
//
//  Created by Tian Lan on 11/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK

class FlagRequestTests: XCTestCase {
    
    func testFlaggingSequence() {
        let mockSequenceID: Int64 = 101
        let flagRequest = FlagRequest(sequenceID: mockSequenceID)
        let urlRequest = flagRequest.urlRequest

        XCTAssertEqual(urlRequest.URL?.absoluteString, "/api/sequence/flag")
        
        guard let bodyData = urlRequest.HTTPBody else {
            XCTFail("No HTTP Body!")
            return
        }
        let bodyString = String(data: bodyData, encoding: NSUTF8StringEncoding)!
        
        XCTAssertNotNil(bodyString.rangeOfString("sequence_id=\(mockSequenceID)"))
    }
    
    func testFlaggingComment() {
        let mockCommentID: Int64 = 1001
        let flagRequest = FlagRequest(commentID: mockCommentID)
        let urlRequest = flagRequest.urlRequest
        
        XCTAssertEqual(urlRequest.URL?.absoluteString, "/api/comment/flag")
        
        guard let bodyData = urlRequest.HTTPBody else {
            XCTFail("No HTTP Body!")
            return
        }
        let bodyString = String(data: bodyData, encoding: NSUTF8StringEncoding)!
        
        XCTAssertNotNil(bodyString.rangeOfString("comment_id=\(mockCommentID)"))
    }
    
    func testFlaggingMessage() {
        let mockMessageID: Int64 = 10001
        let flagRequest = FlagRequest(messageID: mockMessageID)
        let urlRequest = flagRequest.urlRequest
        
        XCTAssertEqual(urlRequest.URL?.absoluteString, "/api/message/flag")
        
        guard let bodyData = urlRequest.HTTPBody else {
            XCTFail("No HTTP Body!")
            return
        }
        let bodyString = String(data: bodyData, encoding: NSUTF8StringEncoding)!
        
        XCTAssertNotNil(bodyString.rangeOfString("message_id=\(mockMessageID)"))
    }
}
