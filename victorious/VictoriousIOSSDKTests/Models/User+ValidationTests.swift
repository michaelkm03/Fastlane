//
//  User+ValidationTests.swift
//  victorious
//
//  Created by Jarod Long on 9/27/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import VictoriousIOSSDK
import XCTest

class UserValidationTests: XCTestCase {
    func testUsernameValidation() {
        XCTAssertNil(User.validationError(forUsername: "valid_username_123"))
        XCTAssertNotNil(User.validationError(forUsername: ""))
        XCTAssertNotNil(User.validationError(forUsername: "a_username_that_is_too_long"))
        XCTAssertNotNil(User.validationError(forUsername: "username with spaces"))
        XCTAssertNotNil(User.validationError(forUsername: "🍔🍕"))
    }
    
    func testDisplayNameValidation() {
        XCTAssertNil(User.validationError(forDisplayName: "This is a Valid Display Name! 🍉"))
        XCTAssertNil(User.validationError(forDisplayName: ""))
        XCTAssertNotNil(User.validationError(forUsername: "This display name is way too long so it should produce an error."))
    }
}
