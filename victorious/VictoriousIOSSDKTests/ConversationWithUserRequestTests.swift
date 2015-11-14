//
//  ConversationWithUserRequestTests.swift
//  victorious
//
//  Created by Michael Sena on 11/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK
import SwiftyJSON

class ConversationWithUserRequestTests: XCTestCase {

    func testConfiguredRequest () {
        let conversationWithUserRequest = ConversationWithUserRequest(userID: 4823)
        XCTAssertEqual(conversationWithUserRequest.userID, 4823)
        XCTAssertEqual(conversationWithUserRequest.urlRequest.URL, NSURL(string: "/api/message/conversation_with_user/4823"))
        let conversationWithUserRequestZero = ConversationWithUserRequest(userID: 0)
        XCTAssertEqual(conversationWithUserRequestZero.urlRequest.URL, NSURL(string: "/api/message/conversation_with_user/0"))
        let conversationWithUserRequestNegativeOne = ConversationWithUserRequest(userID: -1)
        XCTAssertEqual(conversationWithUserRequestNegativeOne.urlRequest.URL, NSURL(string: "/api/message/conversation_with_user/-1"))
    }
    
    func testResponseParsing() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("ConversationWithUserFoundResponse", withExtension: "json"), let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
            XCTFail("Error reading mock json data.")
            return
        }
        
        let conversationWithUserRequest = ConversationWithUserRequest(userID: 4823)
        let result: (conversationID: Int64, messages: [Message]) = try! conversationWithUserRequest.parseResponse(NSURLResponse(), toRequest: conversationWithUserRequest.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
        
        XCTAssertEqual(result.messages.count, 1)
        XCTAssertEqual(result.conversationID, 3809)
        if let firstMessage = result.messages.first {
            XCTAssertEqual(firstMessage.messageID, 8768)
        }
    }
}
