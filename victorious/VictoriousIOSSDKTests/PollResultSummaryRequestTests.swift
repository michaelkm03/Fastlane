//
//  PollResultSummaryRequestTests.swift
//  victorious
//
//  Created by Tian Lan on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK
import SwiftyJSON

class PollResultSummaryRequestTests: XCTestCase {
    
    func testRequestBySequence() {
        let mockSequenceID: String = "101"
        let pollResultRequest = PollResultSummaryRequest(sequenceID: mockSequenceID)
        let urlRequest = pollResultRequest.urlRequest
        
        XCTAssertEqual(urlRequest.URL?.absoluteString, "/api/pollresult/summary_by_sequence/\(mockSequenceID)")
    }
    
    func testRequestByUser() {
        let mockUserID: Int64 = 101
        let pollResultRequest = PollResultSummaryRequest(userID: mockUserID)
        let urlRequest = pollResultRequest.urlRequest
        
        XCTAssertEqual(urlRequest.URL?.absoluteString, "/api/pollresult/summary_by_user/\(mockUserID)")
    }
    
    func testValidResponseUser() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("PollResultByUserResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        do {
            let pollResultRequest = PollResultSummaryRequest(userID: 101)
            
            let results: [PollResult] = try pollResultRequest.parseResponse(NSURLResponse(), toRequest: pollResultRequest.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            if results.count == 15 {
                XCTAssertEqual(results[0].sequenceID, "14609")
                XCTAssertEqual(results[0].answerID, 744)
                XCTAssertEqual(results[1].sequenceID, "15064")
                XCTAssertEqual(results[1].answerID, 834)
                XCTAssertEqual(results[2].sequenceID, "15585")
                XCTAssertEqual(results[2].answerID, 855)
            } else {
                XCTAssertEqual(results.count, 15)
            }
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
    
    func testValidResponseSequence() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("PollResultBySequenceResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        do {
            let pollResultRequest = PollResultSummaryRequest(sequenceID: "101")
            
            let results = try pollResultRequest.parseResponse(NSURLResponse(), toRequest: pollResultRequest.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertEqual(results.count, 2)
            XCTAssertEqual(results[0].totalCount, 4)
            XCTAssertEqual(results[0].answerID, 384)
            XCTAssertEqual(results[1].totalCount, 3)
            XCTAssertEqual(results[1].answerID, 383)
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
    
    func testInvalidResponseUser() {
        do {
            let data = "{ \"payload\" : [{},{}] }".dataUsingEncoding(NSUTF8StringEncoding)!
            let pollResultRequest = PollResultSummaryRequest(sequenceID: "101")
            
            let results = try pollResultRequest.parseResponse(NSURLResponse(), toRequest: pollResultRequest.urlRequest, responseData: data, responseJSON: JSON(data: data) )
            XCTAssertEqual(results.count, 0)
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
    
    func testInvalidResponseSequence() {
        do {
            let data = "{ \"payload\" : [{},{}] }".dataUsingEncoding(NSUTF8StringEncoding)!
            let pollResultRequest = PollResultSummaryRequest(sequenceID: "101")
            
            let results = try pollResultRequest.parseResponse(NSURLResponse(), toRequest: pollResultRequest.urlRequest, responseData: data, responseJSON: JSON(data: data) )
            XCTAssertEqual(results.count, 0)
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
}
