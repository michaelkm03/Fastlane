//
//  DeleteSequenceRequestTests.swift
//  victorious
//
//  Created by Tian Lan on 11/13/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK

class DeleteSequenceRequestTests: XCTestCase {
    
    func testDeletingSequenceRequest() {
        let mockSequenceID: String = "101"
        let deleteRequest = DeleteSequenceRequest(sequenceID: mockSequenceID)
        let urlRequest = deleteRequest.urlRequest
        
        XCTAssertEqual(urlRequest.URL?.absoluteString, "/api/sequence/remove")
        
        guard let bodyData = urlRequest.HTTPBody else {
            XCTFail("No HTTP Body!")
            return
        }
        let bodyString = String(data: bodyData, encoding: NSUTF8StringEncoding)!
        
        XCTAssertNotNil(bodyString.rangeOfString("sequence_id=\(mockSequenceID)"))
    }
}
