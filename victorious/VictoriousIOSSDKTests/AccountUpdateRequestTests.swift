//
//  AccountUpdateRequestTests.swift
//  victorious
//
//  Created by Josh Hinman on 11/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import VictoriousIOSSDK
import XCTest

class AccountUpdateRequestTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRequestWithProfile() {
        let updateRequest = AccountUpdateRequest(
            profileUpdate: ProfileUpdate(
                email: "joe@example.com",
                name: "Joe Victorious",
                location: "Bethesda, MD",
                tagline: "Example",
                profileImageURL: nil
            )
        )
        XCTAssertEqual(updateRequest?.urlRequest.URL?.absoluteString, "/api/account/update")
    }
    
    func testRequestWithPassword() {
        let updateRequest = AccountUpdateRequest(
            passwordUpdate: PasswordUpdate(
                username: "joe@example.com",
                currentPassword: "password",
                newPassword: "password_new"
            )
        )
        XCTAssertEqual(updateRequest?.urlRequest.URL?.absoluteString, "/api/account/update")
    }
    
    func testResponseParsing() {
        guard let mockUserDataURL = NSBundle(forClass: self.dynamicType).URLForResource("AccountUpdateResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockUserDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        guard let updateRequest = AccountUpdateRequest(profileUpdate: ProfileUpdate(
            email: "joe@example.com",
            name: "Joe Victorious",
            location: "Bethesda, MD",
            tagline: "Example",
            profileImageURL: nil
        )) else {
            XCTFail("Could not instantiate AccountUpdateRequest")
            return
        }
        
        do {
            let user = try updateRequest.parseResponse(NSURLResponse(), toRequest: NSURLRequest(), responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertEqual(user.id, 156)
            XCTAssertEqual(user.displayName, "Joe Victorious")
        } catch {
            XCTFail("parseResponse is not supposed to throw")
        }
        
        guard let updatePasswordRequest = AccountUpdateRequest(passwordUpdate: PasswordUpdate(
            username: "joe@example.com",
            currentPassword: "password",
            newPassword: "password_new"
        )) else {
            XCTFail("Could not instantiate AccountUpdateRequest")
            return
        }
        
        do {
            let user = try updatePasswordRequest.parseResponse(NSURLResponse(), toRequest: NSURLRequest(), responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertEqual(user.id, 156)
            XCTAssertEqual(user.displayName, "Joe Victorious")
        } catch {
            XCTFail("parseResponse is not supposed to throw")
        }
    }
}
