//
//  FlagCommentRequestTests.swift
//  victorious
//
//  Created by Tian Lan on 11/13/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK

class FlagCommentRequestTests: XCTestCase {
    
    func testFlaggingCommentRequest() {
        let mockCommentID: Int64 = 1001
        let flagRequest = FlagCommentRequest(commentID: mockCommentID)
        let urlRequest = flagRequest.urlRequest
        
        XCTAssertEqual(urlRequest.URL?.absoluteString, "/api/comment/flag")
        
        guard let bodyData = urlRequest.HTTPBody else {
            XCTFail("No HTTP Body!")
            return
        }
        let bodyString = String(data: bodyData, encoding: NSUTF8StringEncoding)!
        
        XCTAssertNotNil(bodyString.rangeOfString("comment_id=\(mockCommentID)"))
    }
}
