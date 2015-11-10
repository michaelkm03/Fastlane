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
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
    
    func testRequest() {
        let suggestedUsersRequest = SuggestedUsersRequest()
        XCTAssertEqual(suggestedUsersRequest.urlRequest.URL?.absoluteString, "/api/discover/suggested_users")
    }
}
