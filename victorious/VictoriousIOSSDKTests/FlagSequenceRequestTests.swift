//
//  FlagSequenceRequestTests.swift
//  victorious
//
//  Created by Tian Lan on 11/13/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK

class FlagSequenceRequestTests: XCTestCase {
    
    func testFlaggingSequenceRequest() {
        let mockSequenceID: Int64 = 101
        let flagRequest = FlagSequenceRequest(sequenceID: mockSequenceID)
        let urlRequest = flagRequest.urlRequest
        
        XCTAssertEqual(urlRequest.URL?.absoluteString, "/api/sequence/flag")
        
        guard let bodyData = urlRequest.HTTPBody else {
            XCTFail("No HTTP Body!")
            return
        }
        let bodyString = String(data: bodyData, encoding: NSUTF8StringEncoding)!
        
        XCTAssertNotNil(bodyString.rangeOfString("sequence_id=\(mockSequenceID)"))
    }
}