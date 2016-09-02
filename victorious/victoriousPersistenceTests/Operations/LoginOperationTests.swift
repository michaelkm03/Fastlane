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
            let currentUser = VCurrentUser.user
            XCTAssertNotNil(VCurrentUser.user)
            XCTAssertEqual(currentUser?.id, 36179)
            
            XCTAssertEqual(VCurrentUser.loginType, VLoginType.Email.rawValue)
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
