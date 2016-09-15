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
            let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLFORResource("ChatRoomsReponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockResponseDataURL)
        else {
            XCTFail("Erorr reading mock json data for Chat Rooms")
        }

        let chatRoomsRequest = ChatRoomsRequest(apiPath: APIPath(templatePath: "")!
        let results = try chatRoomsRequest.parseResponse(NSURLResponse(), toRequest: chatRoomsRequest.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData) {
            XCTAssertEqual(results.count, 2)
            XCTAssertEqual(results[0].topic, "Cupcakes")
            XCTAssertEqual(results[1].topic, "Cholocate")
        }
    }
}
