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
    
    private let persistentStore: PersistentStoreType = PersistentStoreSelector.mainPersistentStore
    
    override func start() {
        super.start()
        
        defer {
            self.finishedExecuting()
        }
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        let storedLogin = VStoredLogin()
        if let info = storedLogin.storedLoginInfo() {
            
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
            
            let id = Int(user.remoteId.integerValue)
            UserInfoOperation( userID: id ).queueAfter( self, queue: Operation.defaultQueue )
      
        } else if let loginType = VLoginType(rawValue: defaults.integerForKey(kLastLoginTypeUserDefaultsKey)),
            let accountIdentifier = defaults.stringForKey(kAccountIdentifierDefaultsKey),
            let credentials = loginType.storedCredentials( accountIdentifier ) {
                
                let accountCreateRequest = AccountCreateRequest(credentials: credentials)
                let operation = AccountCreateOperation(
                    request: accountCreateRequest,
                    loginType: loginType,
                    accountIdentifier: accountIdentifier
                )
                operation.queueAfter( self, queue: Operation.defaultQueue )
      
        } else {
            // Nothing to do here without a stored token or credentials to log in.
            // Subsequent operations in the queue will handle logging in the user
            // after this operation completes without creating a valid user object.
        }
    }
}
