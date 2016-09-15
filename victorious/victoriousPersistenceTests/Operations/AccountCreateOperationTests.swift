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
    
    let token = "ads98j0yd08as7hd9s8a76dghsa87das"
    let twitterToken = "dsaliuho87ao2e"
    let twitterSecret = "dsa9jy7ads8"
    let twitterID = "future_patrick"

    let accountIdentifier = ""
    
    override func setUp() {
        super.setUp()
        do { try self.persistentStore.deletePersistentStore() } catch {}
    }

    func testFacebook() {
        guard let user = self.loadUser() else {
            XCTFail( "Failed to load sample user" )
            return
        }
        
        let credentials: NewAccountCredentials = .Facebook(accessToken: token)
        let accountCreateRequest = AccountCreateRequest(credentials: credentials)
        let operation = AccountCreateOperation(
            request: accountCreateRequest,
            loginType: .Facebook,
            accountIdentifier: accountIdentifier
        )
        
        let response = AccountCreateResponse(
            token: token,
            user: user,
            newUser: false
        )

        let expectation = expectationWithDescription("testFacebook")
        operation.onComplete(response) {
            guard let persistentUser: VUser = self.persistentStore.mainContext.v_findObjects(["remoteId" : user.userID ]).first else {
                XCTFail( "Unable to load the user the operation should have parsed." )
                return
            }

            XCTAssertEqual( persistentUser.loginType?.integerValue ?? -1, VLoginType.Facebook.rawValue )
            XCTAssertEqual( persistentUser.token, self.token )

            let currentUser = VCurrentUser.user
            XCTAssertNotNil( VCurrentUser.user )
            XCTAssertEqual( persistentUser.objectID, currentUser?.objectID )

            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testEmailAndPassword() {
        guard let user = self.loadUser(), let email = user.email else {
            XCTFail( "Failed to load sample user" )
            return
        }
        
        let credentials: NewAccountCredentials = .EmailPassword(email: email, password: "password")
        let accountCreateRequest = AccountCreateRequest(credentials: credentials)
        let operation = AccountCreateOperation(
            request: accountCreateRequest,
            loginType: .Email,
            accountIdentifier: accountIdentifier
        )
        
        let response = AccountCreateResponse(
            token: token,
            user: user,
            newUser: false
        )
        
        let expectation = expectationWithDescription("testEmailAndPassword")
        operation.onComplete(response) {
            guard let persistentUser: VUser = self.persistentStore.mainContext.v_findObjects(["remoteId" : user.userID ]).first else {
                XCTFail( "Unable to load the user the operation should have parsed." )
                return
            }
            
            XCTAssertEqual( persistentUser.loginType?.integerValue ?? -1, VLoginType.Email.rawValue )
            XCTAssertEqual( persistentUser.token, self.token )
            
            let currentUser = VCurrentUser.user
            XCTAssertNotNil( VCurrentUser.user )
            XCTAssertEqual( persistentUser.objectID, currentUser?.objectID )
            
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testTwitter() {
        guard let user = self.loadUser() else {
            XCTFail( "Failed to load sample user" )
            return
        }

        let credentials: NewAccountCredentials = .Twitter(accessToken: twitterToken, accessSecret: twitterSecret, twitterID: twitterID)
        let accountCreateRequest = AccountCreateRequest(credentials: credentials)
        let operation = AccountCreateOperation(
            request: accountCreateRequest,
            loginType: .Twitter,
            accountIdentifier: accountIdentifier
        )
        
        let response = AccountCreateResponse(
            token: token,
            user: user,
            newUser: false
        )
        
        let expectation = expectationWithDescription("testTwitter")
        operation.onComplete(response) {
            guard let persistentUser: VUser = self.persistentStore.mainContext.v_findObjects(["remoteId" : user.userID ]).first else {
                XCTFail( "Unable to load the user the operation should have parsed." )
                return
            }
            
            XCTAssertEqual( persistentUser.loginType?.integerValue ?? -1, VLoginType.Twitter.rawValue )
            XCTAssertEqual( persistentUser.token, self.token )
            
            let currentUser = VCurrentUser.user
            XCTAssertNotNil( VCurrentUser.user )
            XCTAssertEqual( persistentUser.objectID, currentUser?.objectID )
            
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    private func loadUser() -> User? {
        guard let mockUserDataURL = NSBundle(forClass: self.dynamicType).URLForResource("User", withExtension: "json"),
              let mockData = NSData(contentsOfURL: mockUserDataURL) else {
            return nil
        }
        return User(json: JSON(data: mockData))
    }
}
