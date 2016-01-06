//
//  DeleteConversationRequestTests.swift
//  victorious
//
//  Created by Tian Lan on 11/13/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK

class DeleteConversationRequestTests: XCTestCase {
    
    func testDeletingConversationRequest() {
        let mockConversationID: Int = 10001
        let deleteRequest = DeleteConversationRequest(conversationID: mockConversationID)
        let urlRequest = deleteRequest.urlRequest
        
        XCTAssertEqual(urlRequest.URL?.absoluteString, "/api/message/delete_conversation")
        
        guard let bodyData = urlRequest.HTTPBody else {
            XCTFail("No HTTP Body!")
            return
        }
        let bodyString = String(data: bodyData, encoding: NSUTF8StringEncoding)!
        
        XCTAssertNotNil(bodyString.rangeOfString("conversation_id=\(mockConversationID)"))
    }
}
