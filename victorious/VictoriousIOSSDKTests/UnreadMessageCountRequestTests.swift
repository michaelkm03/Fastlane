//
//  UnreadMessageCountRequestTests.swift
//  victorious
//
//  Created by Michael Sena on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK
import SwiftyJSON



class UnreadMessageCountRequestTests: XCTestCase {
    
    func testRequest() {
        let unreadMessageCount = UnreadMessageCountRequest()
        XCTAssertEqual(unreadMessageCount.urlRequest.URL?.absoluteString, "/api/message/unread_message_count")
    }
    
    func testResponseParsing() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("UnreadMessageCountResponse", withExtension: "json"), let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
            XCTFail("Error reading mock json data.")
            return
        }
        
        do {
            let unreadMessageCount = UnreadMessageCountRequest()
            let unreadCount = try unreadMessageCount.parseResponse(NSURLResponse(), toRequest: unreadMessageCount.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertEqual(unreadCount, 0)
        } catch {
            XCTFail("Sorry, parseResponse should not throw here.")
        }
    }    
}
