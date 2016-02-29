//
//  UserInfoRequestTests.swift
//  victorious
//
//  Created by Patrick Lynch on 11/13/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
@testable import VictoriousIOSSDK

class UserInfoRequestTests: XCTestCase {
    
    func testConfiguredRequest() {
        let id: Int = 3694
        let request =  UserInfoRequest(userID: id )
        XCTAssertEqual( request.urlRequest.URL, NSURL(string: "/api/userinfo/fetch/\(id)") )
        XCTAssertEqual( request.userID, id )
        XCTAssertEqual( request.urlRequest.HTTPMethod, "GET" )
    }
    
    func testParseResponse() {
        
        guard let mockUserDataURL = NSBundle(forClass: self.dynamicType).URLForResource("UserInfoResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockUserDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        let id: Int = 3694
        let request =  UserInfoRequest(userID: id)
        let user: User
        do {
            user = try request.parseResponse(NSURLResponse(), toRequest: NSURLRequest(), responseData: mockData, responseJSON: JSON(data: mockData))
        } catch {
            XCTFail("parseResponse is not supposed to throw")
            return
        }
        
        XCTAssertEqual( user.userID, id )
    }
}
