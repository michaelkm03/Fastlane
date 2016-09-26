//
//  ChatRoomTests.swift
//  victorious
//
//  Created by Alex Tamoykin on 9/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK

class ChatRoomTests: XCTestCase {
    func testJSONParsing() {
        guard
            let mockDataURL = NSBundle(forClass: self.dynamicType).URLForResource("ChatRoom", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockDataURL) else {
                XCTFail("Failed to read mock json data")
                return
        }
        guard let chatroom = ChatRoom(json: JSON(data: mockData)) else {
            XCTFail("Failed to initialize a ChatRoom with data: \(mockData)")
            return
        }
        XCTAssertEqual(chatroom.name, "Cupcakes")
    }

    func testInitailizer() {
        let chatRoom = ChatRoom(name: "Seasalt")
        XCTAssertEqual(chatRoom.name, "Seasalt")
    }
}
