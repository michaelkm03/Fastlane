//
//  LoginOperationTests.swift
//  victorious
//
//  Created by Tian Lan on 2/10/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
import SwiftyJSON
@testable import victorious

class LoginOperationTests: BaseRequestOperationTestCase {
    
    func testLogin() {
        guard let user = self.loadUser(), let email = user.email else {
            XCTFail( "Failed to load sample user" )
            return
        }
        let operation = LoginOperation(email: email, password: "password")
        
        operation.persistentStore = TestPersistentStore()
        operation.requestExecutor = TestRequestExecutor()
        
        
        let token = "ABCDEFGabcdefg"
        let response = LoginResponse(token: token, user: user)

        
        let expectation = expectationWithDescription("testLoginWithEmailAndPassword")
        operation.onComplete(response) {
            guard let persistentUser: VUser = operation.persistentStore.mainContext.v_findObjects(["remoteId" : user.userID ]).first else {
                XCTFail( "Unable to load the user the operation should have parsed." )
                return
            }
            
            XCTAssertEqual( persistentUser.loginType?.integerValue ?? -1, VLoginType.Email.rawValue )
            XCTAssertEqual( persistentUser.token, token )
            
            let currentUser = VCurrentUser.user()
            XCTAssertNotNil( VCurrentUser.user() )
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
