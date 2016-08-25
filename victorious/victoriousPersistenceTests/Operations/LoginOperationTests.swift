//
//  LoginOperationTests.swift
//  victorious
//
//  Created by Tian Lan on 2/10/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class LoginOperationTests: BaseFetcherOperationTestCase {
    
    func testLogin() {
        guard let user = self.loadUser(), let email = user.username else {
            XCTFail( "Failed to load sample user" )
            return
        }
        
        let operation = LoginOperation(
            dependencyManager: VDependencyManager.dependencyManagerWithDefaultValuesForColorsAndFonts(),
            email: email,
            password: "password"
        )
        
        XCTAssertFalse( operation.requiresAuthorization )
        
        let token = "ABCDEFGabcdefg"
        let response = AccountCreateResponse(token: token, user: user)
        operation.requestExecutor = TestRequestExecutor(result: response)
        
        let expectation = expectationWithDescription("testLoginWithEmailAndPassword")
        operation.queue() { results, error, cancelled in
            
            guard let persistentUser: VUser = self.testStore.mainContext.v_findObjects(["remoteId" : user.id ]).first else {
                XCTFail( "Unable to load the user the operation should have parsed." )
                return
            }
            
            XCTAssertEqual( persistentUser.loginType, VLoginType.Email.rawValue )
            
            let currentUser = VCurrentUser.user
            XCTAssertNotNil( VCurrentUser.user )
            XCTAssertEqual( persistentUser.objectID, currentUser?.objectID )
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(expectationThreshold, handler: nil)
    }
    
    private func loadUser() -> User? {
        guard let mockUserDataURL = NSBundle(forClass: self.dynamicType).URLForResource("User", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockUserDataURL) else {
                return nil
        }
        return User(json: JSON(data: mockData))
    }
}
