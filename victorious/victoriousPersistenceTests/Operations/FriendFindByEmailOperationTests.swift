//
//  FriendFindByEmailOperationTests.swift
//  victorious
//
//  Created by Michael Sena on 1/5/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class FriendFindByEmailOperationTests: BaseRequestOperationTests {
    
    var operation: FriendFindByEmailOperation!
    let emails = ["h@h.hh", "mike@msena.com"]

    override func setUp() {
        super.setUp()

        operation = FriendFindByEmailOperation(emails:emails)
    }
    
    func testSomething() {
        //TODO: finish me
    }

}
