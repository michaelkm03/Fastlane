//
//  ChatMessageInboundTests.swift
//  victorious
//
//  Created by Sebastian Nystorm on 31/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import VictoriousIOSSDK

class ChatMessageInboundTests : XCTestCase {

    func testInitialization() {
        guard let chatMessageJSONURL = NSBundle(forClass: self.dynamicType).URLForResource("ChatMessageInbound", withExtension: "json"),
            let jsonData = NSData(contentsOfURL: chatMessageJSONURL) else {
                XCTFail("Error reading ChatMessageInbound JSON data.")
                return
        }
        guard let chatMessage = ChatMessageInbound(json: JSON(data: jsonData), timestamp: NSDate(timeIntervalSince1970:1234567890)) else {
            XCTFail("ChatMessageInbound initializer failed.")
            return
        }
        
        XCTAssertEqual(chatMessage.text, "Test message")
        XCTAssertEqual(chatMessage.giphyUrl, NSURL(string:"http://a.url.to.giphy"))
        XCTAssertEqual(chatMessage.contentURL, NSURL(string:"http://a.url.to.content"))
        XCTAssertNotNil(chatMessage.fromUser)
    }
}
