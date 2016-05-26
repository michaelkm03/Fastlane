//
//  SuggestedUsersRequestTests.swift
//  victorious
//
//  Created by Tian Lan on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest

@testable import VictoriousIOSSDK

class SuggestedUsersRequestTests: XCTestCase {
    
    func testResponseParsing() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("SuggestedUsersResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        do {
            let suggestedUsersRequest = SuggestedUsersRequest()
            let results = try suggestedUsersRequest.parseResponse(NSURLResponse(), toRequest: suggestedUsersRequest.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertEqual(results.count, 5)
            
            XCTAssertEqual(results[0].user.id, 3694)
            XCTAssertEqual(results[0].recentSequences.count, 10)
            XCTAssertEqual(results[0].recentSequences[0].sequenceID, "16543")
            
            XCTAssertEqual(results[1].user.id, 97)
            XCTAssertEqual(results[1].recentSequences.count, 10)
            XCTAssertEqual(results[1].recentSequences[0].sequenceID, "16393")

            XCTAssertEqual(results[2].user.id, 708)
            XCTAssertEqual(results[2].recentSequences.count, 9)
            XCTAssertEqual(results[2].recentSequences[0].sequenceID, "12683")

            XCTAssertEqual(results[3].user.id, 2956)
            XCTAssertEqual(results[3].recentSequences.count, 10)
            XCTAssertEqual(results[3].recentSequences[0].sequenceID, "16891")

            XCTAssertEqual(results[4].user.id, 1419)
            XCTAssertEqual(results[4].recentSequences.count, 5)
            XCTAssertEqual(results[4].recentSequences[0].sequenceID, "16547")
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
    
    func testRequest() {
        let suggestedUsersRequest = SuggestedUsersRequest()
        XCTAssertEqual(suggestedUsersRequest.urlRequest.URL?.absoluteString, "/api/discover/suggested_users")
    }
}
