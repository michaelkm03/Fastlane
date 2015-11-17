//
//  PostCommentRequestTests.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/12/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import SwiftyJSON
import VictoriousIOSSDK
import XCTest

class PostCommentRequestTests: XCTestCase {
    
    func testRequest() {
        let postCommentRequest = PostCommentRequest(sequenceID: 17100, text: "test", mediaAttachmentType: nil, mediaURL: nil)
        XCTAssertEqual(postCommentRequest?.urlRequest.URL?.absoluteString, "/api/comment/add")
    }
    
    func testResponseParsing() {
        guard let mockUserDataURL = NSBundle(forClass: self.dynamicType).URLForResource("PostCommentResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockUserDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        guard let postCommentRequest = PostCommentRequest(sequenceID: 17100, text: "test", mediaAttachmentType: nil, mediaURL: nil) else {
            XCTFail("Could not instantiate AccountUpdateRequest")
            return
        }
        
        do {
            let comment = try postCommentRequest.parseResponse(NSURLResponse(), toRequest: NSURLRequest(), responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertEqual(comment.remoteID, 28612)
            XCTAssertEqual(comment.text, "test")
        } catch {
            XCTFail("parseResponse is not supposed to throw")
        }
    }
}
