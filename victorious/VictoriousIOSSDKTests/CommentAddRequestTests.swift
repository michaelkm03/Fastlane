//
//  CommentAddRequestTests.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/12/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import SwiftyJSON
import VictoriousIOSSDK
import XCTest

// TODO: Finish
class CommentAddRequestTests: XCTestCase {
    
    let textOnlyParameters = CommentParameters(
        sequenceID: 17100,
        text: "test",
        mediaURL: nil,
        mediaType: nil,
        realtimeComment: nil
    )
    
    func testRequest() {
        
        let postCommentRequest = CommentAddRequest(parameters: textOnlyParameters)!
        XCTAssertNotNil( postCommentRequest )
        XCTAssertEqual(postCommentRequest.urlRequest.URL?.absoluteString, "/api/comment/add")
    }
    
    func testResponseParsing() {
        guard let mockUserDataURL = NSBundle(forClass: self.dynamicType).URLForResource("PostCommentResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockUserDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        guard let postCommentRequest = CommentAddRequest(parameters: textOnlyParameters) else {
            XCTFail("Could not instantiate AccountUpdateRequest")
            return
        }
        
        do {
            let comment = try postCommentRequest.parseResponse(NSURLResponse(), toRequest: NSURLRequest(), responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertEqual(comment.commentID, 28612)
            XCTAssertEqual(comment.text, "test")
        } catch {
            XCTFail("parseResponse is not supposed to throw")
        }
    }
}
