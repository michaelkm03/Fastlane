//
//  ConversationListRequestTests.swift
//  victorious
//
//  Created by Michael Sena on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK
import SwiftyJSON

class ConversationListRequestTests: XCTestCase {

    func testRequestFormatting() {
        let conversationListRequest = ConversationListRequest(pageNumber: 1, itemsPerPage: 99)
        XCTAssertEqual(conversationListRequest.urlRequest.URL?.absoluteString, "/api/message/conversation_list/1/99")
    }

    func testResponseParsing() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("ConversationListResponse", withExtension: "json"), let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
            XCTFail("Error reading mock json data.")
            return
        }
        
        do {
            let conversationListRequest = ConversationListRequest(pageNumber: 1, itemsPerPage: 10)
            let (results, _, _) = try conversationListRequest.parseResponse(NSURLResponse(), toRequest: conversationListRequest.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            
            XCTAssert(results.count  > 0)
            if let firstConversation = results.first {
                XCTAssertEqual(firstConversation.conversationID, 3075)
                XCTAssertEqual(firstConversation.isRead, true)
                XCTAssertEqual(firstConversation.recipient.name, "Düüd")
                XCTAssertEqual(firstConversation.previewMessageID, 7793)
                XCTAssertEqual(firstConversation.previewMessageText, "a")
                XCTAssertEqual(firstConversation.thumbnailURL, NSURL(string:"http://media-dev-public.s3-website-us-west-1.amazonaws.com/24084340f4a29cf68d9e2f6edbe39953/80x80.jpg"))
                XCTAssertEqual(firstConversation.mediaURL, NSURL(string:"http://media-dev-public.s3-website-us-west-1.amazonaws.com/24084340f4a29cf68d9e2f6edbe39953/80x80.jpg"))
                XCTAssertEqual(firstConversation.mediaType, "image")

                // Test Date parsing
                let dateFormatter = NSDateFormatter(format: DateFormat.Standard)
                let testDate = dateFormatter.dateFromString("2015-08-28 23:25:31")
                XCTAssertEqual(firstConversation.postedAt, testDate)
            }
            else {
                XCTFail("We should have at least one conversation.")
            }
            
        } catch {
            XCTFail("Sorry, parseResponse should not throw here.")
        }
    }
    
    func testDefaults() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("ConversationListResponse", withExtension: "json"), let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
            XCTFail("Error reading mock json data.")
            return
        }
        
        do {
            let conversationListRequest = ConversationListRequest(pageNumber: 1, itemsPerPage: 10)
            let (results, _, _) = try conversationListRequest.parseResponse(NSURLResponse(), toRequest: conversationListRequest.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            let secondConversation = results[1]
            XCTAssertEqual(secondConversation.isRead, true)
        } catch {
            XCTFail("Sorry, parseResponse should not throw here.")
        }
    }
    
    func testNoConversations() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("NoConversationsConversationListResponse", withExtension: "json"), let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
            XCTFail("Error reading mock json data.")
            return
        }
        
        do {
            let conversationListRequest = ConversationListRequest(pageNumber: 1, itemsPerPage: 10)
            let (results, _, _) = try conversationListRequest.parseResponse(NSURLResponse(), toRequest: conversationListRequest.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            
            XCTAssertEqual(results.count, 0)
        } catch {
            XCTFail("Sorry, parseResponse should not throw here.")
        }
    }
    
    func testInvalid() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("InvalidConversationListResponse", withExtension: "json"), let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
            XCTFail("Error reading mock json data.")
            return
        }
        
        do {
            let conversationListRequest = ConversationListRequest(pageNumber: 1, itemsPerPage: 10)
            let (results, _, _) = try conversationListRequest.parseResponse(NSURLResponse(), toRequest: conversationListRequest.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertEqual(results.count, 0)
        } catch {
            XCTFail("We Sorry, parseResponse should not throw here.")
        }
    }
}
