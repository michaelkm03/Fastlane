//
//  UnlikeSequenceRequestTests.swift
//  victorious
//
//  Created by Tian Lan on 11/23/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK

class UnlikeSequenceRequestTests: XCTestCase {
    
    func testRequest() {
        let mockSequenceID: Int64 = 101
        let unlikeRequest = UnlikeSequenceRequest(sequenceID: mockSequenceID)
        let urlRequest = unlikeRequest.urlRequest
        
        XCTAssertEqual(urlRequest.URL?.absoluteString, "/api/sequence/unlike")
        
        guard let bodyData = urlRequest.HTTPBody else {
            XCTFail("No HTTP Body!")
            return
        }
        let bodyString = String(data: bodyData, encoding: NSUTF8StringEncoding)!
        
        XCTAssertNotNil(bodyString.rangeOfString("sequence_id=\(mockSequenceID)"))
    }
}
