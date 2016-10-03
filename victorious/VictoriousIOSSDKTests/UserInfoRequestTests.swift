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
    fileprivate static let apiPath = APIPath(templatePath: "http://api.getvictorious.com/my/cool/path/%%USER_ID%%")
    
    func testRequestConfigurationWithAPIPath() {
        let id = 9090
        let request = UserInfoRequest(apiPath: UserInfoRequestTests.apiPath, userID: id)!
        XCTAssertEqual(request.urlRequest.url, URL(string: "http://api.getvictorious.com/my/cool/path/\(id)"))
    }
    
    func testParseResponse() {
        guard let mockUserDataURL = Bundle(for: type(of: self)).url(forResource: "UserInfoResponse", withExtension: "json"),
            let mockData = try? Data(contentsOf: mockUserDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        let id: Int = 3694
        let request =  UserInfoRequest(apiPath: UserInfoRequestTests.apiPath, userID: id)!
        let user: User
        do {
            user = try request.parseResponse(URLResponse(), toRequest: URLRequest(), responseData: mockData, responseJSON: JSON(data: mockData))
        } catch {
            XCTFail("parseResponse is not supposed to throw")
            return
        }
        
        XCTAssertEqual( user.id, id )
    }
}
