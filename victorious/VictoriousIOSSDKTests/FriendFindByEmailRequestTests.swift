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

}
