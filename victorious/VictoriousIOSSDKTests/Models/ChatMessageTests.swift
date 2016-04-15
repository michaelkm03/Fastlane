//
//  ChatMessageTests.swift
//  victorious
//
//  Created by Sebastian Nystorm on 31/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import VictoriousIOSSDK

class ChatMessageTests : XCTestCase {

    func testInitialization() {
        guard let chatMessageJSONURL = NSBundle(forClass: self.dynamicType).URLForResource("ChatMessageInbound", withExtension: "json"),
            let jsonData = NSData(contentsOfURL: chatMessageJSONURL) else {
                XCTFail("Error reading ChatMessage JSON data.")
                return
        }
        let json = JSON(data: jsonData)
        guard let chatMessage = ChatMessage(json: json, timestamp: NSDate(timeIntervalSince1970:1234567890)) else {
            XCTFail("ChatMessage initializer failed.")
            return
        }
        
        XCTAssertEqual(chatMessage.text, "Test message")
        XCTAssertNotNil(chatMessage.fromUser)
    }
}
