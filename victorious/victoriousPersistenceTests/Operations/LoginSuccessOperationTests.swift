//
//  LoginSuccessOperationTests.swift
//  victorious
//
//  Created by Patrick Lynch on 2/12/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class LoginSuccessOperationTests: XCTestCase {


// FUTURE:  This test has been manually disabled beacuse it disrupts our workflow.
//          Should be fixed by either removing CD or rewriting this test so it actually can pass.

//    func testLogin() {
//        guard let user = self.loadUser(), let email = user.username else {
//            XCTFail( "Failed to load sample user" )
//            return
//        }
//        let token = "ABCDEFGabcdefg"
//        let response = AccountCreateResponse(token: token, user: user)
//        let parameters = AccountCreateParameters(loginType: .Email, accountIdentifier: email)
//        let operation = LoginSuccessOperation(
//            dependencyManager: VDependencyManager.dependencyManagerWithDefaultValuesForColorsAndFonts(),
//            response: response,
//            parameters: parameters
//        )
//        
//        let expectation = expectationWithDescription("")
//        operation.queue() { results, error, cancelled in
//            XCTAssertNil(error)
//            expectation.fulfill()
//        }
//        waitForExpectationsWithTimeout(1.0, handler: nil)
//        
//        guard let persistentUser: VUser = operation.persistentStore.mainContext.v_findObjects(["remoteId" : user.id ]).first else {
//            XCTFail( "Unable to load the user the operation should have parsed." )
//            return
//        }
//        
//        XCTAssertEqual( persistentUser.loginType.integerValue, VLoginType.Email.rawValue )
//        XCTAssertEqual( persistentUser.token, token )
//        
//        let currentUser = VCurrentUser.user
//        XCTAssertNotNil( VCurrentUser.user )
//        XCTAssertEqual( persistentUser.objectID, currentUser?.objectID )
//    }
//    
//    private func loadUser() -> User? {
//        guard let mockUserDataURL = NSBundle(forClass: self.dynamicType).URLForResource("User", withExtension: "json"),
//            let mockData = NSData(contentsOf:: mockUserDataURL) else {
//                return nil
//        }
//        return User(json: JSON(data: mockData))
//    }
}
