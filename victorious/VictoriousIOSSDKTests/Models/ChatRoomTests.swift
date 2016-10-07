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
            let mockDataURL = Bundle(for: type(of: self)).url(forResource: "ChatRoom", withExtension: "json"),
            let mockData = try? Data(contentsOf: mockDataURL) else {
                XCTFail("Failed to read mock json data")
                return
        }
        guard let chatroom = ChatRoom(json: JSON(data: mockData)) else {
            XCTFail("Failed to initialize a ChatRoom with data: \(mockData)")
            return
        }
        XCTAssertEqual(chatroom.id, "cupcakes")
        XCTAssertEqual(chatroom.name, "Cupcakes")
    }

    func testInitailizer() {
        let chatRoom = ChatRoom(id: "sea_salt", name: "Seasalt")
        XCTAssertEqual(chatRoom.id, "sea_salt")
        XCTAssertEqual(chatRoom.name, "Seasalt")
    }
}
