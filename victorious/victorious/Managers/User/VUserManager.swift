//
//  VUserManager.swift
//  victorious
//
//  Created by Josh Hinman on 10/27/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import CoreData
import FBSDKCoreKit
import Foundation
import VictoriousIOSSDK

extension VUserManager {
    
    /// Log in using Twitter oauth data.
    func loginViaTwitterWithToken(oauthToken: String, accessSecret: String, twitterID: String, identifier: String, onCompletion completionBlock: VUserManagerLoginCompletionBlock, onError errorBlock: VUserManagerLoginErrorBlock) -> Cancelable {
        
        let objectManager = VObjectManager.sharedManager()
        let accountCreateRequest = AccountCreateRequest(credentials: .Twitter(accessToken: oauthToken, accessSecret: accessSecret, twitterID: twitterID))
        return objectManager.executeRequest(accountCreateRequest) { (result, error) in
            if let result = result {
                dispatch_async(dispatch_get_main_queue()) {
                    NSUserDefaults.standardUserDefaults().setInteger(VLoginType.Twitter.rawValue, forKey: kLastLoginTypeUserDefaultsKey)
                    NSUserDefaults.standardUserDefaults().setObject(twitterID, forKey: kAccountIdentifierDefaultsKey)
                    // TODO: completionBlock(user, result.newUser)
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    errorBlock(error as? NSError, false)
                }
            }
        }
    }
    
    func logout() {
        guard VUser.currentUser(inContext: PersistentStore.mainContext) != nil else {
            self.logoutDidFinish()
            return
        }
        
        LogoutOperation().queue() { error in
            self.logoutDidFinish()
        }
    }
    
    private func logoutDidFinish() {}
    
    private func loginDidFinish(persistentUser: VUser) {}
}
