//
//  LoginSuccessOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 2/12/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
import SwiftyJSON
@testable import victorious

class LoginSuccessOperationTests: BaseRequestOperationTestCase {
    
    func testLogin() {
        guard let user = self.loadUser(), let email = user.email else {
            XCTFail( "Failed to load sample user" )
            return
        }
        let token = "ABCDEFGabcdefg"
        let response = AccountCreateResponse(token: token, user: user)
        let parameters = AccountCreateParameters(loginType: .Email, accountIdentifier: email)
        let operation = LoginSuccessOperation(response: response, parameters: parameters)
        
        operation.persistentStore = TestPersistentStore()
        operation.main()
        
        guard let persistentUser: VUser = operation.persistentStore.mainContext.v_findObjects(["remoteId" : user.userID ]).first else {
            XCTFail( "Unable to load the user the operation should have parsed." )
            return
        }
        
        XCTAssertEqual( persistentUser.loginType?.integerValue ?? -1, VLoginType.Email.rawValue )
        XCTAssertEqual( persistentUser.token, token )
        
        let currentUser = VCurrentUser.user()
        XCTAssertNotNil( VCurrentUser.user() )
        XCTAssertEqual( persistentUser.objectID, currentUser?.objectID )
    }
    
    
    private func loadUser() -> User? {
        guard let mockUserDataURL = NSBundle(forClass: self.dynamicType).URLForResource("User", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockUserDataURL) else {
                return nil
        }
        return User(json: JSON(data: mockData))
    }
}
