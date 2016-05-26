//
//  ConversationRequestTests.swift
//  victorious
//
//  Created by Michael Sena on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK

class ConversationRequestTests: XCTestCase {
    
    let dateFormatter = NSDateFormatter(vsdk_format: DateFormat.Standard)

    func testRequest() {
        let paginator = StandardPaginator(pageNumber: 1, itemsPerPage: 99)
        let conversationRequest = ConversationRequest(conversationID: 3797, userID: 97, paginator:paginator)
        XCTAssertEqual(conversationRequest.urlRequest.URL?.absoluteString, "/api/message/conversation/3797/desc/1/99")
    }
    
    func testResponseParsing() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("ConversationResponse", withExtension: "json"), let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
            XCTFail("Error reading mock json data.")
            return
        }
        
        let paginator = StandardPaginator(pageNumber: 1, itemsPerPage: 99)
        let conversationRequest = ConversationRequest(conversationID: 3797, userID:97, paginator: paginator)
        let results = try! conversationRequest.parseResponse(NSURLResponse(), toRequest: conversationRequest.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))

        XCTAssertEqual(results.count, 1)
        if let firstMessage = results.first {
            XCTAssertEqual(firstMessage.text, "this is a test")
            XCTAssertEqual(firstMessage.isRead, true)
            XCTAssertEqual(firstMessage.messageID, 8749)
            XCTAssertEqual(firstMessage.sender?.id, 97)
            XCTAssertEqual(firstMessage.mediaAttachment?.thumbnailURL, NSURL(string: "http://media-dev-public.s3-website-us-west-1.amazonaws.com/d7b465ba8581b0f4828086b3e99d77d0/thumbnail-00001.jpg"))
            XCTAssertEqual(firstMessage.mediaAttachment?.url, NSURL(string: "http://media-dev-public.s3-website-us-west-1.amazonaws.com/d7b465ba8581b0f4828086b3e99d77d0/playlist.m3u8"))
            XCTAssertEqual(firstMessage.mediaAttachment?.type, .Video)
            
            // Test MediaAttachment Parsing
            if let formats = firstMessage.mediaAttachment?.formats {
                
                XCTAssertEqual(formats.count, 2)
                if let firstFormat = formats.first {
                    XCTAssertEqual(firstFormat.mimeType, MimeType.HLSStream)
                    XCTAssertEqual(firstFormat.url, NSURL(string: "http://media-dev-public.s3-website-us-west-1.amazonaws.com/d7b465ba8581b0f4828086b3e99d77d0/playlist.m3u8"))
                }
                if formats.count > 1 {
                   let secondFormat = formats[1]
                    XCTAssertEqual(secondFormat.mimeType, MimeType.MP4)
                    XCTAssertEqual(secondFormat.url, NSURL(string: "http://media-dev-public.s3-website-us-west-1.amazonaws.com/d7b465ba8581b0f4828086b3e99d77d0/720/video.mp4"))
                }
            }
            else {
                XCTFail("This message should have multiple formats for its attachment.")
            }
            
            // Test Date parsing
            let testDate = dateFormatter.dateFromString("2015-11-10 03:09:52")
            XCTAssertEqual(firstMessage.postedAt, testDate)
        }
    }

    func testDefaults() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("MinDataConverationResponse", withExtension: "json"), let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
            XCTFail("Error reading mock json data.")
            return
        }
        
        let paginator = StandardPaginator(pageNumber: 1, itemsPerPage: 99)
        let conversationRequest = ConversationRequest(conversationID: 3797, userID: 97, paginator: paginator)
        let results = try! conversationRequest.parseResponse(NSURLResponse(), toRequest: conversationRequest.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
        
        XCTAssertEqual(results.count, 1)
        if let firstMessage = results.first {
            XCTAssertEqual(firstMessage.messageID, 8749)
            XCTAssertEqual(firstMessage.sender?.id, 97)
            XCTAssertNil(firstMessage.text)
            XCTAssertNil(firstMessage.isRead)
            XCTAssertNil(firstMessage.mediaAttachment)
            let testDate = dateFormatter.dateFromString("2016-01-13 20:33:33")
            XCTAssertEqual(firstMessage.postedAt, testDate)
        }
    }
    
    func testNoMessages() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("NoDataConverationResponse", withExtension: "json"), let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
            XCTFail("Error reading mock json data.")
            return
        }
        
        let paginator = StandardPaginator(pageNumber: 1, itemsPerPage: 99)
        let conversationRequest = ConversationRequest(conversationID: 3797, userID: 97, paginator: paginator)
        let results = try! conversationRequest.parseResponse(NSURLResponse(), toRequest: conversationRequest.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))

        XCTAssertEqual(results.count, 0)
    }
    
    func testInvalid() {
        
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("InvalidDataConverationResponse", withExtension: "json"), let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
            XCTFail("Error reading mock json data.")
            return
        }
        
        let paginator = StandardPaginator(pageNumber: 1, itemsPerPage: 99)
        let conversationRequest = ConversationRequest(conversationID: 3797, userID: 97, paginator: paginator)
        let results = try! conversationRequest.parseResponse(NSURLResponse(), toRequest: conversationRequest.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
        
        XCTAssertEqual(results.count, 0)
    }
}
