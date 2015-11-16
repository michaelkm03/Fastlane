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
    
    func queueLoginOperationWithFacebook() -> NSOperation {
        let loginType = VLoginType.Facebook
        let credentials: NewAccountCredentials = loginType.storedCredentials()!
        let accountCreateRequest = AccountCreateRequest(credentials: credentials)
        let operation = AccountCreateOperation( request: accountCreateRequest, loginType: loginType )
        operation.queue() { error in
            if error == nil {
                self.actionsDisabled = false
                self.isRegisteredAsNewUser = operation.isNewUser
                self.continueRegistrationFlowAfterSocialRegistration()
            } else {
                self.handleFacebookLoginError(error)
            }
            self.completion?(error == nil)
        }
        return operation
    }
    
    func queueLoginOperationWithTwitter(oauthToken: String, accessSecret: String, twitterID: String, identifier: String) -> NSOperation {
        let loginType = VLoginType.Twitter
        let credentials: NewAccountCredentials = .Twitter(accessToken: oauthToken, accessSecret: accessSecret, twitterID: twitterID)
        let accountCreateRequest = AccountCreateRequest(credentials: credentials)
        let operation = AccountCreateOperation( request: accountCreateRequest, loginType: loginType )
        operation.queue()  { error in
            if error == nil {
                self.actionsDisabled = false
                self.isRegisteredAsNewUser = operation.isNewUser
                self.continueRegistrationFlowAfterSocialRegistration()
            } else {
                self.handleTwitterLoginError(error)
            }
            self.completion?(error == nil)
        }
        return operation
    }
    
    func queueLoginOperationWithEmail(email: String, password: String, completion:(NSError?)->() ) -> NSOperation {
        let accountCreateRequest = AccountCreateRequest(credentials: .EmailPassword(email: email, password: password))
        let operation = AccountCreateOperation( request: accountCreateRequest, loginType: .Email, accountIdentifier: email )
        operation.queue( completion )
        return operation
    }
}
