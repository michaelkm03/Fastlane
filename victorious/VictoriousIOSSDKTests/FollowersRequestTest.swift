//
//  FollowersRequestTest.swift
//  victorious
//
//  Created by Tian Lan on 11/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK
import SwiftyJSON

class FollowersRequestTest: XCTestCase {
    
    func testResponseParsing() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("FollowersResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        do {
            let followersRequest = FollowersRequest(userID: 100)
            let (results, _, previousPage) = try followersRequest.parseResponse(NSURLResponse(), toRequest: followersRequest.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertEqual(results.count, 3)
            XCTAssertEqual(results[0].userID, 576)
            XCTAssertEqual(results[0].name, "Ksnd")
            XCTAssertEqual(results[1].userID, 1794)
            XCTAssertEqual(results[1].name, "Me!")
            XCTAssertEqual(results[2].userID, 2613)
            XCTAssertEqual(results[2].name, "Sebastian")
            
            XCTAssertNil(previousPage, "There should be no page before page 1")
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
    
    func testRequest() {
        let followersRequest = FollowersRequest(userID: 101, pageNumber: 102, itemsPerPage: 103)
        XCTAssertEqual(followersRequest.urlRequest.URL?.absoluteString, "/api/follow/followers_list/101/102/103")
    }
    
    func testPreviousPage() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("FollowersResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        do {
            let followersRequest = FollowersRequest(userID: 101, pageNumber: 2, itemsPerPage: 102)
            let (_, _, previousPage) = try followersRequest.parseResponse(NSURLResponse(), toRequest: followersRequest.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertEqual(previousPage?.urlRequest.URL?.absoluteString, "/api/follow/followers_list/101/1/102")
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
    
    func testNextPage() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("SequenceLikersResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        do {
            let followersRequest = FollowersRequest(userID: 101, pageNumber: 1, itemsPerPage: 102)
            let (_, nextPage, _) = try followersRequest.parseResponse(NSURLResponse(), toRequest: followersRequest.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertEqual(nextPage?.urlRequest.URL?.absoluteString, "/api/follow/followers_list/101/2/102")
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
    
    func testNoNextPageForEmptyResponse() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("SequenceLikersEmptyResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        do {
            let followersRequest = FollowersRequest(userID: 101, pageNumber: 1, itemsPerPage: 102)
            let (_, nextPage, _) = try followersRequest.parseResponse(NSURLResponse(), toRequest: followersRequest.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertNil(nextPage)
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
}
