//
//  ConversationListRequestTests.swift
//  victorious
//
//  Created by Michael Sena on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK

class ConversationListRequestTests: XCTestCase {
    
    func testRequestFormatting() {
        let paginator = StandardPaginator(pageNumber: 1, itemsPerPage: 99)
        let conversationListRequest = ConversationListRequest( paginator: paginator )
        XCTAssertEqual(conversationListRequest.urlRequest.URL?.absoluteString, "/api/message/conversation_list/1/99")
    }

    func testResponseParsing() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("ConversationListResponse", withExtension: "json"), let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
            XCTFail("Error reading mock json data.")
            return
        }
        
        do {
            
            let paginator = StandardPaginator( pageNumber: 1, itemsPerPage: 10 )
            let conversationListRequest = ConversationListRequest(paginator: paginator)
            let results = try conversationListRequest.parseResponse(NSURLResponse(), toRequest: conversationListRequest.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            
            XCTAssert(results.count  > 0)
            if let firstConversation = results.first {
                XCTAssertEqual(firstConversation.conversationID, 3075)
                XCTAssertEqual(firstConversation.isRead, true)
                XCTAssertEqual(firstConversation.otherUser.displayName, "Düüd")
                XCTAssertEqual(firstConversation.previewMessageID, 7793)
                XCTAssertEqual(firstConversation.previewMessageText, "a")

                // Test Date parsing
                let dateFormatter = NSDateFormatter(vsdk_format: DateFormat.Standard)
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
            let paginator = StandardPaginator(pageNumber: 1, itemsPerPage: 10)
            let conversationListRequest = ConversationListRequest(paginator: paginator)
            let results = try conversationListRequest.parseResponse(NSURLResponse(), toRequest: conversationListRequest.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            let secondConversation = results[1]
            XCTAssertNil(secondConversation.isRead)
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
            let paginator = StandardPaginator(pageNumber: 1, itemsPerPage: 10)
            let conversationListRequest = ConversationListRequest(paginator: paginator)
            let results = try conversationListRequest.parseResponse(NSURLResponse(), toRequest: conversationListRequest.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
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
            let paginator = StandardPaginator(pageNumber: 1, itemsPerPage: 10)
            let conversationListRequest = ConversationListRequest(paginator: paginator)
            let results = try conversationListRequest.parseResponse(NSURLResponse(), toRequest: conversationListRequest.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertEqual(results.count, 0)
        } catch {
            XCTFail("We Sorry, parseResponse should not throw here.")
        }
    }
}
