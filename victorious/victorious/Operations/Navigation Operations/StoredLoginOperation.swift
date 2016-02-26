//
//  StoredLoginOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class StoredLoginOperation: Operation {
    
    private let persistentStore: PersistentStoreType = PersistentStoreSelector.defaultPersistentStore
    
    override func start() {
        super.start()
        
        defer {
            self.finishedExecuting()
        }
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let accountIdentifier: String? = defaults.stringForKey(kAccountIdentifierDefaultsKey)
        
        let storedLogin = VStoredLogin()
        if let info = storedLogin.storedLoginInfo() {
            
            // First, try to use a valid stored token to bypass login
            let user: VUser = persistentStore.mainContext.v_performBlockAndWait() { context in
                let user: VUser = context.v_findOrCreateObject([ "remoteId" : info.userRemoteId ])
                user.loginType = info.lastLoginType.rawValue
                user.token = info.token
                if user.status == nil {
                    user.status = "stored"
                }
                context.v_save()
                return user
            }
            user.setAsCurrentUser()
            
            PreloadUserInfoOperation().after(self).queue()
            
        } else if let loginType = VLoginType(rawValue: defaults.integerForKey(kLastLoginTypeUserDefaultsKey)),
            let credentials = loginType.storedCredentials( accountIdentifier ) {
                
                // Next, if login with a stored token failed, use any stored credentials to login automatically
                let accountCreateRequest = AccountCreateRequest(credentials: credentials)
                let accountCreateOperation = AccountCreateOperation(
                    request: accountCreateRequest,
                    parameters: AccountCreateParameters(
                        loginType: loginType,
                        accountIdentifier: accountIdentifier
                    )
                )
                accountCreateOperation.rechainAfter(self).queue()
                
        } else {
            // Or finally, just let this operation finish up without doing anthing.
            // Subsequent operations in the queue will handle logging in the user.
        }
    }
}
