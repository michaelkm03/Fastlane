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
    
    func testRequest() {
        let sendMessageRequest = SendMessageRequest(recipientID: 1908, text: "Hi", mediaAttachmentType: nil, mediaURL: nil)
        XCTAssertEqual(sendMessageRequest?.urlRequest.URL?.absoluteString, "/api/message/send")
    }
    
    func testResponseParsing() {
        guard let mockUserDataURL = NSBundle(forClass: self.dynamicType).URLForResource("SendMessageResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockUserDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        guard let sendMessageRequest = SendMessageRequest(recipientID: 1908, text: "Hi", mediaAttachmentType: nil, mediaURL: nil) else {
            XCTFail("Could not instantiate AccountUpdateRequest")
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
