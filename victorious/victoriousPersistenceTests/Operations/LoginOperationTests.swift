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
        
        let token = "ABCDEFGabcdefg"
        let response = AccountCreateResponse(token: token, user: user)
        
        let operation = LoginOperation(email: email, password: "password")
        
        operation.persistentStore = TestPersistentStore()
        operation.requestExecutor = TestRequestExecutor(result: response)
        
        let expectation = expectationWithDescription("testLoginWithEmailAndPassword")
        operation.queueOn(testQueue) { (results, error) in
            
            let dependentOperations = operation.v_defaultQueue.v_dependentOperationsOf(operation)
            XCTAssertEqual( dependentOperations.count, 1 );
            guard let successOperation = dependentOperations.first as? LoginSuccessOperation else {
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
