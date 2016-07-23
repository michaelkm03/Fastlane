//
//  FriendFindByEmailRequestTests.swift
//  victorious
//
//  Created by Michael Sena on 1/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import VictoriousIOSSDK

class FriendFindByEmailRequestTests: XCTestCase {

    var request: FriendFindByEmailRequest!
    
    override func setUp() {
        super.setUp()
        
        let emails = ["h@h.hh", "mike@msena.com"]
        guard let request = FriendFindByEmailRequest(emails: emails) else {
            XCTFail("This request should not fail in it's initializer")
            return
        }
        self.request = request
    }
    
    func testRequest() {
        XCTAssertEqual(request.urlRequest.URL, NSURL(string: "/api/friend/find_by_email"))
        
        let emptyEmails = [String]()
        let shouldBeNilRequest = FriendFindByEmailRequest(emails: emptyEmails)
        XCTAssertNil(shouldBeNilRequest)
    }
    
    func testShouldFailInitializer() {
        let emails = [String]()
        let shouldBeNilRequest = FriendFindByEmailRequest(emails: emails)
        XCTAssertNil(shouldBeNilRequest)
    }

    func testParseResponse() {
        
        guard let mockUserDataURL = NSBundle(forClass: self.dynamicType).URLForResource("FriendFindByEmailResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockUserDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        do {
            let foundFriends = try request.parseResponse(NSURLResponse(), toRequest: NSURLRequest(), responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertFalse(foundFriends.isEmpty)
            if let firstUser = foundFriends.first {
                XCTAssertEqual(firstUser.displayName, "Mikes")
            } else {
                XCTFail("we should have at least one user here")
            }
        } catch {
            XCTFail("parseResponse is not supposed to throw")
            return
        }
    }
    
}
