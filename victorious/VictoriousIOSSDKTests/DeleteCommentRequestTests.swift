//
//  DeleteCommentRequestTests.swift
//  victorious
//
//  Created by Tian Lan on 11/13/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK

class DeleteCommentRequestTests: XCTestCase {
    
    func testDeletingCommentWithoutReasonRequest() {
        let mockCommentID: Int64 = 1001
        let deleteRequest = DeleteCommentRequest(commentID: mockCommentID, removalReason: nil)
        let urlRequest = deleteRequest.urlRequest
        
        XCTAssertEqual(urlRequest.URL?.absoluteString, "/api/comment/remove")
        
        guard let bodyData = urlRequest.HTTPBody else {
            XCTFail("No HTTP Body!")
            return
        }
        let bodyString = String(data: bodyData, encoding: NSUTF8StringEncoding)!
        
        XCTAssertNotNil(bodyString.rangeOfString("comment_id=\(mockCommentID)"))
        XCTAssertNil(bodyString.rangeOfString("removal_reason"))
    }
    
    func testDeletingCommentWithReasonRequest() {
        let mockCommentID: Int64 = 1002
        let mockRemovalReason = "I just feel like to"
        let deleteRequest = DeleteCommentRequest(commentID: mockCommentID, removalReason: mockRemovalReason)
        let urlRequest = deleteRequest.urlRequest
        
        XCTAssertEqual(urlRequest.URL?.absoluteString, "/api/comment/remove")
        
        guard let bodyData = urlRequest.HTTPBody else {
            XCTFail("No HTTP Body!")
            return
        }
        let bodyString = String(data: bodyData, encoding: NSUTF8StringEncoding)!
        let absoluteBodyString = bodyString.stringByRemovingPercentEncoding!
        
        XCTAssertNotNil(absoluteBodyString.rangeOfString("comment_id=\(mockCommentID)"))
        XCTAssertNotNil(absoluteBodyString.rangeOfString("removal_reason=\(mockRemovalReason)"))
    }
}
