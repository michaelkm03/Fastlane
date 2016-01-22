//
//  SendMessageRequestTests.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import SwiftyJSON
import VictoriousIOSSDK
import XCTest

class SendMessageRequestTests: XCTestCase {
    
    let creationParameters = Message.CreationParameters(
        text: "Hello!",
        recipientID: 1564,
        conversationID: 153,
        mediaAttachment: nil
    )
    
    func testRequest() {
        guard let request = SendMessageRequest(creationParameters: creationParameters) else {
            XCTFail("Unable to create request")
            return
        }
        
        let urlRequest = request.urlRequest
        XCTAssertEqual(urlRequest.HTTPMethod, "POST")
        XCTAssertEqual(urlRequest.URL?.absoluteString, "/api/message/send")
    }
    
    func testResponseParsing() {
        guard let mockUserDataURL = NSBundle(forClass: self.dynamicType).URLForResource("SendMessageResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockUserDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        guard let sendMessageRequest = SendMessageRequest(creationParameters: creationParameters) else {
            XCTFail("Could not instantiate SendMessageRequest")
            return
        }
        
        do {
            let (conversationID, messageID) = try sendMessageRequest.parseResponse(NSURLResponse(), toRequest: NSURLRequest(), responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertEqual(conversationID, 3875)
            XCTAssertEqual(messageID, 8847)
        } catch {
            XCTFail("parseResponse is not supposed to throw")
        }
    }
}
