//
//  PollResultByUserRequestTests.swift
//  victorious
//
//  Created by Tian Lan on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK
import SwiftyJSON

class PollResultByUserRequestTests: XCTestCase {
    
    func testRequest() {
        let mockUserID: Int64 = 101
        let pollResultRequest = PollResultByUserRequest(userID: mockUserID)
        let urlRequest = pollResultRequest.urlRequest
        
        XCTAssertEqual(urlRequest.URL?.absoluteString, "/api/pollresult/summary_by_user/\(mockUserID)")
    }
    
    func testValidResponse() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("PollResultByUserResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        do {
            let pollResultRequest = PollResultByUserRequest(userID: 101)
            
            let results = try pollResultRequest.parseResponse(NSURLResponse(), toRequest: pollResultRequest.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertEqual(results.count, 10)
            XCTAssertEqual(results[0].sequenceID, 405130)
            XCTAssertEqual(results[0].answerID, 123)
            XCTAssertEqual(results[1].sequenceID, 420812)
            XCTAssertEqual(results[1].answerID, 123)
            XCTAssertEqual(results[2].sequenceID, 643629)
            XCTAssertEqual(results[2].answerID, 1234)
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
    
    func testInvalidResponse() {
        guard let mockInvalidResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("PollResultBySequenceResponse", withExtension: "json"),
            let mockInvalidData = NSData(contentsOfURL: mockInvalidResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        do {
            let pollResultRequest = PollResultByUserRequest(userID: 101)
        
            let results = try pollResultRequest.parseResponse(NSURLResponse(), toRequest: pollResultRequest.urlRequest, responseData: mockInvalidData, responseJSON: JSON(data: mockInvalidData))
            XCTAssertEqual(results.count, 0)
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
}
