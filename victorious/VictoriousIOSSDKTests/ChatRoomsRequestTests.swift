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
            XCTAssertEqual(results.count, 2)
            XCTAssertEqual(results[0].name, "Cupcakes")
            XCTAssertEqual(results[1].name, "Cholocate")
        } catch {
            XCTFail("Oh nooo, exception thrown during json parsing :-(")
        }
    }
}
