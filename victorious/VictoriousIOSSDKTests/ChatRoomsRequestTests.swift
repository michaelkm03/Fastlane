//
//  ChatRoomsRequestTests.swift
//  victorious
//
//  Created by Alex Tamoykin on 9/14/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK

class ChatRoomsRequestTests: XCTestCase {
    func testResponseParsing() {
        guard
            let mockResponseDataURL = Bundle(for: type(of: self)).url(forResource: "ChatRoomsResponse", withExtension: "json"),
            let mockData = try? Data(contentsOf: mockResponseDataURL)
        else {
            XCTFail("Error reading mock json data for Chat Rooms")
            return
        }

        let chatRoomsRequest = ChatRoomsRequest(apiPath: APIPath(templatePath: "foo"))!
        do {
            let results = try chatRoomsRequest.parseResponse(URLResponse(), toRequest: chatRoomsRequest.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            let room1 = results[0], room2 = results[1]
            XCTAssertEqual(results.count, 2)
            XCTAssertEqual(room1.name, "Cupcakes")
            XCTAssertEqual(room1.id, "cupcakes")
            XCTAssertEqual(room2.name, "Cholocate")
            XCTAssertEqual(room2.id, "chocolate")
        } catch {
            XCTFail("Oh nooo, exception thrown during json parsing 😔")
        }
    }
}
