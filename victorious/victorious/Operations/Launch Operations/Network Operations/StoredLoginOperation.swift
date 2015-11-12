//
//  StoredLoginOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class StoredLoginOperation: NetworkOperation {
    
    override func start() {
        super.start()
        
        defer {
            self.finishedExecuting()
        }
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        let storedLogin = VStoredLogin()
        if let info = storedLogin.storedLoginInfo() {
            
            let dataStore = PersistentStore.mainContext
            let user: VUser = dataStore.findOrCreateObject( [ "remoteId" : info.userRemoteId ])
            user.loginType = info.lastLoginType.rawValue
            user.token = info.token
            user.setCurrentUser(inContext: dataStore)
            dataStore.saveChanges()
            
            // TODO: Fetch soem more user info by adding more operations
            // api/follow/counts/%d
            // api/sequence/users_interactions/%@/%@
        }
        else if let loginType = VLoginType(rawValue: defaults.integerForKey(kLastLoginTypeUserDefaultsKey)),
            let accountIdentifier = defaults.stringForKey(kAccountIdentifierDefaultsKey),
            let credentials = loginType.storedCredentials( accountIdentifier ) {
                
                let accountCreateRequest = AccountCreateRequest(credentials: credentials)
                let operation = AccountCreateOperation(
                    request: accountCreateRequest,
                    loginType: loginType,
                    accountIdentifier: accountIdentifier
                )
                self.queueNext(operation)
        }
        else {
            // No nothing bceause we can't login withjout a stored token or credentials
        }
    }
}
