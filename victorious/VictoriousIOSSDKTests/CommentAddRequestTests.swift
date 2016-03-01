//
//  CommentAddRequestTests.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/12/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import VictoriousIOSSDK
import XCTest

class CommentAddRequestTests: XCTestCase {
    
    let textOnlyParameters = Comment.CreationParameters(
        text: "test",
        sequenceID: "17100",
        replyToCommentID: 1564,
        mediaAttachment: nil,
        realtimeAttachment: nil
    )
    
    func testTextOnlyRequest() {
        let request = CommentAddRequest(creationParameters: textOnlyParameters)!
        XCTAssertNotNil( request )
        XCTAssertEqual( request.urlRequest.URL?.absoluteString, "/api/comment/add" )
        XCTAssertEqual( request.urlRequest.HTTPMethod, "POST" )
    }
    
    func testRealtimeRequest() {
        let params = Comment.CreationParameters(
            text: "test",
            sequenceID: "17100",
            replyToCommentID: nil,
            mediaAttachment: nil,
            realtimeAttachment: Comment.RealtimeAttachment(time: 0.54, assetID: 999)
        )
        
        let request = CommentAddRequest(creationParameters: params)!
        XCTAssertNotNil( request )
        XCTAssertEqual( request.urlRequest.URL?.absoluteString, "/api/comment/add" )
        XCTAssertEqual( request.urlRequest.HTTPMethod, "POST" )
    }
    
    func testMediaRequest() {
        let params = Comment.CreationParameters(
            text: nil,
            sequenceID: "17100",
            replyToCommentID: nil,
            mediaAttachment: nil,
            realtimeAttachment: nil
        )
        let request = CommentAddRequest(creationParameters: params)!
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
        let request = CommentAddRequest(creationParameters: textOnlyParameters)!
        
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
