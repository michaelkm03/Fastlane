//
//  SuggestedUsersRequestTests.swift
//  victorious
//
//  Created by Tian Lan on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import SwiftyJSON
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
            let (results, _, _) = try suggestedUsersRequest.parseResponse(NSURLResponse(), toRequest: suggestedUsersRequest.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertEqual(results.count, 5)
            
            XCTAssertEqual(results[0].user.userID, 3694)
            XCTAssertEqual(results[0].recentSequences.count, 10)
            
            XCTAssertEqual(results[1].user.userID, 97)
            XCTAssertEqual(results[1].recentSequences.count, 10)

            XCTAssertEqual(results[2].user.userID, 708)
            XCTAssertEqual(results[2].recentSequences.count, 10)

            XCTAssertEqual(results[3].user.userID, 2956)
            XCTAssertEqual(results[3].recentSequences.count, 10)

            XCTAssertEqual(results[4].user.userID, 1419)
            XCTAssertEqual(results[4].recentSequences.count, 10)
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
    
    func testRequest() {
        let suggestedUsersRequest = SuggestedUsersRequest()
        XCTAssertEqual(suggestedUsersRequest.urlRequest.URL?.absoluteString, "/api/discover/suggested_users")
    }
}
