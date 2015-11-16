//
//  PollResultBySequenceRequestTests.swift
//  victorious
//
//  Created by Tian Lan on 11/12/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK
import SwiftyJSON

class PollResultBySequenceRequestTests: XCTestCase {
    
    func testRequest() {
        let mockSequenceID: Int64 = 101
        let pollResultRequest = PollResultBySequenceRequest(sequenceID: mockSequenceID)
        let urlRequest = pollResultRequest.urlRequest
        
        XCTAssertEqual(urlRequest.URL?.absoluteString, "/api/pollresult/summary_by_sequence/\(mockSequenceID)")
    }
    
    func testValidResponse() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("PollResultBySequenceResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        do {
            let pollResultRequest = PollResultBySequenceRequest(sequenceID: 101)
            
            let results = try pollResultRequest.parseResponse(NSURLResponse(), toRequest: pollResultRequest.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertEqual(results.count, 2)
            XCTAssertEqual(results[0].voteID, 384)
            XCTAssertEqual(results[0].voteCount, 1)
            XCTAssertEqual(results[1].voteID, 383)
            XCTAssertEqual(results[1].voteCount, 1)
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
    
    func testInvalidResponse() {
        guard let mockInvalidResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("PollResultByUserResponse", withExtension: "json"),
            let mockInvalidData = NSData(contentsOfURL: mockInvalidResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        do {
            let pollResultRequest = PollResultBySequenceRequest(sequenceID: 101)
            
            let results = try pollResultRequest.parseResponse(NSURLResponse(), toRequest: pollResultRequest.urlRequest, responseData: mockInvalidData, responseJSON: JSON(data: mockInvalidData))
            XCTAssertEqual(results.count, 0)
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
}
