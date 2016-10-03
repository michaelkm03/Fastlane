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

    func testRequestWithProfile() {
        let updateRequest = AccountUpdateRequest(
            profileUpdate: ProfileUpdate(
                displayName: "Joe Victorious",
                username: "joe",
                location: "Bethesda, MD",
                tagline: "Example",
                profileImageURL: nil
            )
        )
        XCTAssertEqual(updateRequest?.urlRequest.url?.absoluteString, "/api/account/update")
    }
    
    func testRequestWithPassword() {
        let updateRequest = AccountUpdateRequest(
            passwordUpdate: PasswordUpdate(
                username: "joe@example.com",
                currentPassword: "password",
                newPassword: "password_new"
            )
        )
        XCTAssertEqual(updateRequest?.urlRequest.url?.absoluteString, "/api/account/update")
    }
    
    func testResponseParsing() {
        guard let mockUserDataURL = Bundle(for: type(of: self)).url(forResource: "AccountUpdateResponse", withExtension: "json"),
            let mockData = try? Data(contentsOf: mockUserDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        guard let updateRequest = AccountUpdateRequest(profileUpdate: ProfileUpdate(
            displayName: "Joe Victorious",
            username: "joe",
            location: "Bethesda, MD",
            tagline: "Example",
            profileImageURL: nil
        )) else {
            XCTFail("Could not instantiate AccountUpdateRequest")
            return
        }
        
        do {
            let user = try updateRequest.parseResponse(URLResponse(), toRequest: URLRequest(url: URL(string: "foo")!), responseData: mockData, responseJSON: JSON(data: mockData))
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
            let user = try updatePasswordRequest.parseResponse(URLResponse(), toRequest: URLRequest(url: URL(string: "foo")!), responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertEqual(user.id, 156)
            XCTAssertEqual(user.displayName, "Joe Victorious")
        } catch {
            XCTFail("parseResponse is not supposed to throw")
        }
    }
}
