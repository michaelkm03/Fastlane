//
//  FlagMessageRequestTests.swift
//  victorious
//
//  Created by Tian Lan on 11/13/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK

class FlagMessageRequestTests: XCTestCase {
    
    func testFlaggingMessageRequest() {
        let mockMessageID: Int64 = 10001
        let flagRequest = FlagMessageRequest(messageID: mockMessageID)
        let urlRequest = flagRequest.urlRequest
        
        XCTAssertEqual(urlRequest.URL?.absoluteString, "/api/message/flag")
        
        guard let bodyData = urlRequest.HTTPBody else {
            XCTFail("No HTTP Body!")
            return
        }
        let bodyString = String(data: bodyData, encoding: NSUTF8StringEncoding)!
        
        XCTAssertNotNil(bodyString.rangeOfString("message_id=\(mockMessageID)"))
    }
    
}
