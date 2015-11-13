//
//  VModernLoginAndRegistrationFlowViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 11/12/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension VModernLoginAndRegistrationFlowViewController {
    
    func queueLoginOperationWithFacebook( completion:(NSError?)->() ) -> NSOperation {
        let loginType = VLoginType.Facebook
        let credentials: NewAccountCredentials = loginType.storedCredentials()!
        let accountCreateRequest = AccountCreateRequest(credentials: credentials)
        let operation = AccountCreateOperation( request: accountCreateRequest, loginType: loginType )
        operation.queue( completion )
        return operation
    }
    
    func queueLoginOperationWithEmail(email: String, password: String, completion:(NSError?)->() ) -> NSOperation {
        let accountCreateRequest = AccountCreateRequest(credentials: .EmailPassword(email: email, password: password))
        let operation = AccountCreateOperation( request: accountCreateRequest, loginType: .Email, accountIdentifier: email )
        operation.queue( completion )
        return operation
    }
}
