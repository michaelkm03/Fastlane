//
//  TrendingUsersRequestTests.swift
//  victorious
//
//  Created by Tian Lan on 1/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK

class TrendingUsersRequestTests: XCTestCase {
    
    func testRequest() {
        let request = TrendingUsersRequest()
        XCTAssertEqual(request.urlRequest.URL?.absoluteString, "/api/discover/users")
    }
    
    func testResponseParsing() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("TrendingUsersResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        do {
            let request = TrendingUsersRequest()
            let results = try request.parseResponse(NSURLResponse(), toRequest: request.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            
            XCTAssertEqual(results.count, 12)
            
            XCTAssertEqual(results[0].id, 1285)
            XCTAssertEqual(results[0].name, "tester")
            
            XCTAssertEqual(results[1].id, 318)
            XCTAssertEqual(results[1].name, "Android Test001")
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
}
