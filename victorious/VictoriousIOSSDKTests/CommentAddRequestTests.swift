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

class CommentAddRequestTests: XCTestCase {
    
    let textOnlyParameters = CommentParameters(
        sequenceID: 17100,
        text: "test",
        replyToCommentID: 1564,
        mediaURL: nil,
        mediaType: nil,
        realtimeComment: nil
    )
    
    func testTextOnlyRequest() {
        let request = CommentAddRequest(parameters: textOnlyParameters)!
        XCTAssertNotNil( request )
        XCTAssertEqual( request.urlRequest.URL?.absoluteString, "/api/comment/add" )
        XCTAssertEqual( request.urlRequest.HTTPMethod, "POST" )
    }
    
    func testRealtimeRequest() {
        let params = CommentParameters(
            sequenceID: 17100,
            text: "test",
            replyToCommentID: nil,
            mediaURL: nil,
            mediaType: nil,
            realtimeComment: CommentParameters.RealtimeComment(time: 0.54, assetID: 999)
        )
        
        let request = CommentAddRequest(parameters: params)!
        XCTAssertNotNil( request )
        XCTAssertEqual( request.urlRequest.URL?.absoluteString, "/api/comment/add" )
        XCTAssertEqual( request.urlRequest.HTTPMethod, "POST" )
    }
    
    func testMediaRequest() {
        guard let mockUserDataURL = NSBundle(forClass: self.dynamicType).URLForResource("test_image", withExtension: "png") else {
            XCTFail("Error reading mock image")
            return
        }
        
        let params = CommentParameters(
            sequenceID: 17100,
            text: nil,
            replyToCommentID: nil,
            mediaURL: mockUserDataURL,
            mediaType: .Image,
            realtimeComment: nil
        )
        let request = CommentAddRequest(parameters: params)!
        XCTAssertNotNil( request )
        XCTAssertEqual( request.urlRequest.URL?.absoluteString, "/api/comment/add" )
        XCTAssertEqual( request.urlRequest.HTTPMethod, "POST" )
    }
    
    func testResponseParsing() {
        guard let mockUserDataURL = NSBundle(forClass: self.dynamicType).URLForResource("PostCommentResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockUserDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        let request = CommentAddRequest(parameters: textOnlyParameters)!
        
        let comment: Comment?
        do {
            comment = try request.parseResponse(NSURLResponse(), toRequest: NSURLRequest(), responseData: mockData, responseJSON: JSON(data: mockData))
        } catch {
            XCTFail("parseResponse is not supposed to throw")
            comment = nil
        }
        
        XCTAssertEqual( comment?.commentID, 28612 )
        XCTAssertEqual( comment?.text, "test" )
    }
}
