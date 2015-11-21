//
//  SequenceDetailListByUserRequestTests.swift
//  victorious
//
//  Created by Tian Lan on 11/20/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK
import SwiftyJSON

class SequenceDetailListByUserRequestTests: XCTestCase {
    
    func testValidRequest() {
        let sequenceList = SequenceDetailListByUserRequest(userID: 101, pageNumber: 102, itemsPerPage: 103)
        XCTAssertEqual(sequenceList.urlRequest.URL?.absoluteString, "/api/sequence/detail_list_by_user/101/102/103")
    }
    
    func testValidResponse() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("SequenceDetailListByUserValidResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        do {
            let sequenceListRequest = SequenceDetailListByUserRequest(userID: 101)
            let (results, _, previousPage) = try sequenceListRequest.parseResponse(NSURLResponse(), toRequest: sequenceListRequest.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            
            XCTAssertEqual(results.count, 3)
            XCTAssertEqual(results[0].sequenceID, 17100)
            XCTAssertEqual(results[1].sequenceID, 16503)
            XCTAssertEqual(results[2].sequenceID, 16502)
            XCTAssertNil(previousPage)
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
    
    func testInvalidResponse() {
        guard let invalidMockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("Hashtag", withExtension: "json"),
            let mockData = NSData(contentsOfURL: invalidMockResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        let sequenceListRequest = SequenceDetailListByUserRequest(userID: 101)
        AssertThrowsSpecific(try sequenceListRequest.parseResponse(NSURLResponse(), toRequest: sequenceListRequest.urlRequest, responseData: mockData, responseJSON: JSON(mockData)), ResponseParsingError())
    }
    
    func testPreviousPage() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("SequenceDetailListByUserValidResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        do {
            let sequenceListRequest = SequenceDetailListByUserRequest(userID: 101, pageNumber: 2, itemsPerPage: 100)
            let (_, _, previousPage) = try sequenceListRequest.parseResponse(NSURLResponse(), toRequest: sequenceListRequest.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertEqual(previousPage?.urlRequest.URL?.absoluteString, "/api/sequence/detail_list_by_user/101/1/100")
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
    
    func testNextPage() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("SequenceDetailListByUserValidResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        do {
            let sequenceListRequest = SequenceDetailListByUserRequest(userID: 101, pageNumber: 1, itemsPerPage: 100)
            let (_, nextPage, _) = try sequenceListRequest.parseResponse(NSURLResponse(), toRequest: sequenceListRequest.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertEqual(nextPage?.urlRequest.URL?.absoluteString, "/api/sequence/detail_list_by_user/101/2/100")
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
}
