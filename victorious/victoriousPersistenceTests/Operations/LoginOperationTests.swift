//
//  LoginOperationTests.swift
//  victorious
//
//  Created by Tian Lan on 2/10/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class LoginOperationTests: XCTestCase {
    func testLogin() {
        guard let user = self.loadUser(), let email = user.username else {
            XCTFail( "Failed to load sample user" )
            return
        }
        
        let operation = LoginOperation(
            dependencyManager: VDependencyManager.withDefaultValuesForColorsAndFonts(),
            email: email,
            password: "password"
        )
        
        let token = "ABCDEFGabcdefg"
        let response = AccountCreateResponse(token: token, user: user)
        operation.requestExecutor = TestRequestExecutor(result: response)
        
        let expectation = self.expectation(description: "testLoginWithEmailAndPassword")
        operation.queue() { result in
            let currentUser = VCurrentUser.user
            XCTAssertNotNil(VCurrentUser.user)
            XCTAssertEqual(currentUser?.id, 36179)
            
            XCTAssertEqual(VCurrentUser.loginType, VLoginType.email)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    fileprivate func loadUser() -> User? {
        guard let mockUserDataURL = Bundle(for: type(of: self)).url(forResource: "User", withExtension: "json"),
            let mockData = try? Data(contentsOf: mockUserDataURL) else {
                return nil
        }
        return User(json: JSON(data: mockData))
    }
}
