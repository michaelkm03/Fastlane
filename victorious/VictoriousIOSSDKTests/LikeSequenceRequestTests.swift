//
//  LikeSequenceRequestTests.swift
//  victorious
//
//  Created by Tian Lan on 11/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK

class LikeSequenceRequestTests: XCTestCase {
    
    func testRequest() {
        let mockSequenceID: String = "101"
        let likeRequest = LikeSequenceRequest(sequenceID: mockSequenceID)
        let urlRequest = likeRequest.urlRequest
        
        XCTAssertEqual(urlRequest.URL?.absoluteString, "/api/sequence/like")
        
        guard let bodyData = urlRequest.HTTPBody else {
            XCTFail("No HTTP Body!")
            return
        }
        let bodyString = String(data: bodyData, encoding: NSUTF8StringEncoding)!
        
        XCTAssertNotNil(bodyString.rangeOfString("sequence_id=\(mockSequenceID)"))
    }
}
