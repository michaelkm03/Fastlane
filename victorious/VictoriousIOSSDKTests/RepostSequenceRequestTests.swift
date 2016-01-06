//
//  RepostSequenceRequestTests.swift
//  victorious
//
//  Created by Tian Lan on 11/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK

class RepostSequenceRequestTests: XCTestCase {
    
    func testRequest() {
        let mockNodeID: Int = 101
        let repostRequest = RepostSequenceRequest(nodeID: mockNodeID)
        let urlRequest = repostRequest.urlRequest
        
        XCTAssertEqual(urlRequest.URL?.absoluteString, "/api/repost/create")
        
        guard let bodyData = urlRequest.HTTPBody else {
            XCTFail("No HTTP Body!")
            return
        }
        let bodyString = String(data: bodyData, encoding: NSUTF8StringEncoding)!
        
        XCTAssertNotNil(bodyString.rangeOfString("parent_node_id=\(mockNodeID)"))
    }
}
