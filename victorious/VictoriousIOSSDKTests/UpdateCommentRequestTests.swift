//
//  UpdateCommentRequestTests.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/12/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import SwiftyJSON
import VictoriousIOSSDK
import XCTest

class UpdateCommentRequestTests: XCTestCase {
    
    func testRequest() {
        
        let fakeCommentID = 99 as Int64
        let fakeCommentText = "problems"
        
        let updateCommentRequest = UpdateCommentRequest(commentID: fakeCommentID, text: fakeCommentText)
        
        XCTAssertEqual(updateCommentRequest.urlRequest.URL?.absoluteString, "/api/comment/edit")
        
        guard let bodyData = updateCommentRequest.urlRequest.HTTPBody else {
            XCTFail("No HTTP Body!")
            return
        }
        let bodyString = String(data: bodyData, encoding: NSUTF8StringEncoding)!
        
        XCTAssertNotNil(bodyString.rangeOfString("comment_id=\(fakeCommentID)"))
        XCTAssertNotNil(bodyString.rangeOfString("text=\(fakeCommentText)"))
    }
    
    func testResponseParsing() {
        guard let mockUserDataURL = NSBundle(forClass: self.dynamicType).URLForResource("UpdateCommentResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockUserDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        let fakeCommentID = 99 as Int64
        let fakeCommentText = "problems"
        
        let updateCommentRequest = UpdateCommentRequest(commentID: fakeCommentID, text: fakeCommentText)
        
        do {
            let response = try updateCommentRequest.parseResponse(NSURLResponse(), toRequest: updateCommentRequest.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertEqual(response.commentID, 28593)
            XCTAssertEqual(response.text, "ttrttefefef")
            XCTAssertEqual(response.user.userID, 2956)
        } catch {
            XCTFail("parseResponse is not supposed to throw")
        }
    }
}
