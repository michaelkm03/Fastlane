//
//  ConversationRequestTests.swift
//  victorious
//
//  Created by Michael Sena on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK
import SwiftyJSON

class ConversationRequestTests: XCTestCase {

    func testRequest() {
        let paginator = StandardPaginator(pageNumber: 1, itemsPerPage: 99)
        let conversationRequest = ConversationRequest(conversationID: 3797, paginator:paginator)
        XCTAssertEqual(conversationRequest.urlRequest.URL?.absoluteString, "/api/message/conversation/3797/desc/1/99")
    }
    
    func testResponseParsing() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("ConversationResponse", withExtension: "json"), let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
            XCTFail("Error reading mock json data.")
            return
        }
        
        let paginator = StandardPaginator(pageNumber: 1, itemsPerPage: 99)
        let conversationRequest = ConversationRequest(conversationID: 3797, paginator: paginator)
        let results = try! conversationRequest.parseResponse(NSURLResponse(), toRequest: conversationRequest.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))

        XCTAssertEqual(results.count, 1)
        if let firstMessage = results.first {
            XCTAssertEqual(firstMessage.text, "this is a test")
            XCTAssertEqual(firstMessage.isRead, true)
            XCTAssertEqual(firstMessage.messageID, 8749)
            XCTAssertEqual(firstMessage.sender!.userID, 97)
            XCTAssertEqual(firstMessage.thumbnailURL, NSURL(string: "http://media-dev-public.s3-website-us-west-1.amazonaws.com/d7b465ba8581b0f4828086b3e99d77d0/thumbnail-00001.jpg"))
            XCTAssertEqual(firstMessage.mediaURL, NSURL(string: "http://media-dev-public.s3-website-us-west-1.amazonaws.com/d7b465ba8581b0f4828086b3e99d77d0/playlist.m3u8"))
            XCTAssertEqual(firstMessage.mediaType, "video")
            XCTAssertEqual(firstMessage.isGIFStyle, false)
            XCTAssertEqual(firstMessage.shouldAutoplay, false)
            // Test Date parsing
            if let parsedDate = firstMessage.postedAt {
                let dateFormatter = NSDateFormatter(format: DateFormat.Standard)
                let testDate = dateFormatter.dateFromString("2015-11-10 03:09:52")
                XCTAssertEqual(parsedDate, testDate)
            } else {
                XCTFail("We should have been able to parse a date.")
            }
        }
    }

    func testDefaults() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("MinDataConverationResponse", withExtension: "json"), let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
            XCTFail("Error reading mock json data.")
            return
        }
        
        let paginator = StandardPaginator(pageNumber: 1, itemsPerPage: 99)
        let conversationRequest = ConversationRequest(conversationID: 3797, paginator: paginator)
        let results = try! conversationRequest.parseResponse(NSURLResponse(), toRequest: conversationRequest.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
        
        XCTAssertEqual(results.count, 1)
        if let firstMessage = results.first {
            XCTAssertEqual(firstMessage.messageID, 8749)
            XCTAssertEqual(firstMessage.sender!.userID, 97)
            XCTAssertNil(firstMessage.text)
            XCTAssertNil(firstMessage.isRead)
            XCTAssertNil(firstMessage.thumbnailURL)
            XCTAssertNil(firstMessage.mediaURL)
            XCTAssertNil(firstMessage.mediaType)
            XCTAssertNil(firstMessage.isGIFStyle)
            XCTAssertNil(firstMessage.shouldAutoplay)
            XCTAssertNil(firstMessage.postedAt)
        }
    }
    
    func testNoMessages() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("NoDataConverationResponse", withExtension: "json"), let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
            XCTFail("Error reading mock json data.")
            return
        }
        
        let paginator = StandardPaginator(pageNumber: 1, itemsPerPage: 99)
        let conversationRequest = ConversationRequest(conversationID: 3797, paginator: paginator)
        let results = try! conversationRequest.parseResponse(NSURLResponse(), toRequest: conversationRequest.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))

        XCTAssertEqual(results.count, 0)
    }
    
    func testInvalid() {
        
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("InvalidDataConverationResponse", withExtension: "json"), let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
            XCTFail("Error reading mock json data.")
            return
        }
        
        let paginator = StandardPaginator(pageNumber: 1, itemsPerPage: 99)
        let conversationRequest = ConversationRequest(conversationID: 3797, paginator: paginator)
        let results = try! conversationRequest.parseResponse(NSURLResponse(), toRequest: conversationRequest.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
        
        XCTAssertEqual(results.count, 0)
    }
}
