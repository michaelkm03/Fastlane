//
//  FriendFindByEmailRequestTests.swift
//  victorious
//
//  Created by Michael Sena on 1/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import VictoriousIOSSDK
import SwiftyJSON

class FriendFindByEmailRequestTests: XCTestCase {

    func testRequest() {
        
        let emails = ["h@h.hh", "mike@msena.com"]
        let request = FriendFindByEmailRequest(emails: emails)!
        XCTAssertEqual(request.urlRequest.URL, NSURL(string: "/api/friend/find_by_email"))
        
        let emptyEmails = [String]()
        let shouldBeNilRequest = FriendFindByEmailRequest(emails: emptyEmails)
        XCTAssertNil(shouldBeNilRequest)
    }

    func testParseResponse() {
        
        guard let mockUserDataURL = NSBundle(forClass: self.dynamicType).URLForResource("FriendFindByEmailResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockUserDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        let emails = ["h@h.hh", "mike@msena.com"]
        let request = FriendFindByEmailRequest(emails: emails)!
        
        do {
            let foundFriends = try request.parseResponse(NSURLResponse(), toRequest: NSURLRequest(), responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertFalse(foundFriends.isEmpty)
            if let firstUser = foundFriends.first {
                XCTAssertEqual(firstUser.name, "Mikes")
            } else {
                XCTFail("we should have at least one user here")
            }
        } catch {
            XCTFail("parseResponse is not supposed to throw")
            return
        }
    }
    
}
