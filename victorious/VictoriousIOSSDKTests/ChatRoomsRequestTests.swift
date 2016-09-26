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
            let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("ChatRoomsResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockResponseDataURL)
        else {
            XCTFail("Error reading mock json data for Chat Rooms")
            return
        }

        let chatRoomsRequest = ChatRoomsRequest(apiPath: APIPath(templatePath: ""))!
        do {
            let results = try chatRoomsRequest.parseResponse(NSURLResponse(), toRequest: chatRoomsRequest.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertEqual(results.count, 2)
            XCTAssertEqual(results[0].name, "Cupcakes")
            XCTAssertEqual(results[1].name, "Cholocate")
        } catch {
            XCTFail("Oh nooo, exception thrown during json parsing :-(")
        }
    }
}
