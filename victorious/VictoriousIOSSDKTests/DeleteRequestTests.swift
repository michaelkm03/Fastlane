//
//  DeleteRequestTests.swift
//  victorious
//
//  Created by Tian Lan on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK

class DeleteRequestTests: XCTestCase {
    func testDeletingSequence() {
        /*
        /api/sequence/remove
        sequence_id: 12345
        */
        
        let mockSequenceID: Int64 = 101
        let deleteRequest = DeleteRequest(sequenceID: mockSequenceID)
        let urlRequest = deleteRequest.urlRequest
        
        XCTAssertEqual(urlRequest.URL?.absoluteString, "/api/sequence/remove")
        
        guard let bodyData = urlRequest.HTTPBody else {
            XCTFail("No HTTP Body!")
            return
        }
        let bodyString = String(data: bodyData, encoding: NSUTF8StringEncoding)!
        
        XCTAssertNotNil(bodyString.rangeOfString("sequence_id=\(mockSequenceID)"))
    }
    
    func testDeletingComment() {
        /*
        /api/message/remove
        comment_id: 28481
        removal_reason: (blank)
        */
        let mockCommentID: Int64 = 1001
        let deleteRequest = DeleteRequest(commentID: mockCommentID)
        let urlRequest = deleteRequest.urlRequest
        
        XCTAssertEqual(urlRequest.URL?.absoluteString, "/api/comment/remove")
        
        guard let bodyData = urlRequest.HTTPBody else {
            XCTFail("No HTTP Body!")
            return
        }
        let bodyString = String(data: bodyData, encoding: NSUTF8StringEncoding)!
        
        XCTAssertNotNil(bodyString.rangeOfString("comment_id=\(mockCommentID)"))
    }
    
    func testDeleteConversation() {
        /*
        /api/message/delete_conversation
        conversation_id: 3289
        */
        let mockConversationID: Int64 = 10001
        let deleteRequest = DeleteRequest(conversationID: mockConversationID)
        let urlRequest = deleteRequest.urlRequest
        
        XCTAssertEqual(urlRequest.URL?.absoluteString, "/api/message/delete_conversation")
        
        guard let bodyData = urlRequest.HTTPBody else {
            XCTFail("No HTTP Body!")
            return
        }
        let bodyString = String(data: bodyData, encoding: NSUTF8StringEncoding)!
        
        XCTAssertNotNil(bodyString.rangeOfString("conversation_id=\(mockConversationID)"))
    }
}
