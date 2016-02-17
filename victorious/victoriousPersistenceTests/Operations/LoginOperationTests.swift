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
        let response = AccountCreateResponse(token: token, user: user)
        
        let expectation = expectationWithDescription("testLoginWithEmailAndPassword")
        operation.onComplete(response) {
            
            XCTAssertEqual( operation.dependentOperationsInQueue().count, 1 );
            guard let successOperation = operation.dependentOperationsInQueue().first as? LoginSuccessOperation else {
                XCTFail("Expecting an operaiton to be queued after onComplete is called.")
                return
            }
            XCTAssertEqual(successOperation.parameters.loginType, VLoginType.Email)
            XCTAssertEqual(successOperation.parameters.accountIdentifier, email)
            
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
