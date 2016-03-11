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
        guard let user = self.loadUser(), let email = user.email else {
            XCTFail( "Failed to load sample user" )
            return
        }
        
        let operation = LoginOperation(email: email, password: "password")
        
        XCTAssertFalse( operation.requiresAuthorization )
        
        let token = "ABCDEFGabcdefg"
        let response = AccountCreateResponse(token: token, user: user)
        operation.requestExecutor = TestRequestExecutor(result: response)
        
        let expectation = expectationWithDescription("testLoginWithEmailAndPassword")
        operation.queue() { results, error, cancelled in
            
            XCTAssertNil( error )
            let dependentOperations = operation.v_defaultQueue.v_dependentOperationsOf(operation)
            XCTAssertEqual( dependentOperations.count, 1 )
            guard let successOperation = dependentOperations.first as? LoginSuccessOperation else {
                XCTFail("Expecting an operaiton to be queued after onComplete is called.")
                return
            }
            XCTAssertEqual(successOperation.parameters.loginType, VLoginType.Email)
            XCTAssertEqual(successOperation.parameters.accountIdentifier, email)
            
            expectation.fulfill()
        }
        
        // Don't allow any of the operation's supporting operations to execute
        operation.v_defaultQueue.suspended = true
        
        waitForExpectationsWithTimeout(expectationThreshold) { error in
            
            // But make sure they've been queued as expected
            XCTAssertEqual( operation.v_defaultQueue.operations.flatMap { $0 as? LoginSuccessOperation }.count, 1)
        }
    }
    
    private func loadUser() -> User? {
        guard let mockUserDataURL = NSBundle(forClass: self.dynamicType).URLForResource("User", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockUserDataURL) else {
                return nil
        }
        return User(json: JSON(data: mockData))
    }
}
