//
//  AccountCreateOperationTests.swift
//  victorious
//
//  Created by Patrick Lynch on 11/23/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK
@testable import victorious

class AccountCreateOperationTests: XCTestCase {
    
    let facebookToken = "ads98j0yd08as7hd9s8a76dghsa87das"
    let email = "daso7jhd8sa@dsadsauih.com"
    let password = "dsaoiuhdoisua"
    let twitterToken = "dsaliuho87ao2e"
    let twitterSecret = "dsa9jy7ads8"
    let twitterID = "future_patrick"

    let accountIdentifier = ""
    
    override func setUp() {
        super.setUp()
    }

    func testFacebook() {
        let credentials: NewAccountCredentials = .Facebook(accessToken: facebookToken)
        let accountCreateRequest = AccountCreateRequest(credentials: credentials)
        let operation = AccountCreateOperation(
            request: accountCreateRequest,
            loginType: .Facebook,
            accountIdentifier: accountIdentifier
        )
    }

    func testEmailAndPassword() {
        let credentials: NewAccountCredentials = .EmailPassword(email: email, password: password)
        let accountCreateRequest = AccountCreateRequest(credentials: credentials)
        let operation = AccountCreateOperation(
            request: accountCreateRequest,
            loginType: .Email,
            accountIdentifier: accountIdentifier
        )
    }

    func testTwitter() {
        let credentials: NewAccountCredentials = .Twitter(accessToken: twitterToken, accessSecret: twitterSecret, twitterID: twitterID)
        let accountCreateRequest = AccountCreateRequest(credentials: credentials)
        let operation = AccountCreateOperation(
            request: accountCreateRequest,
            loginType: .Twitter,
            accountIdentifier: accountIdentifier
        )
    }
}
