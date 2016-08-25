//
//  StoredLoginOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class StoredLoginOperation: SyncOperation<Void> {
    
    private let dependencyManager: VDependencyManager
    private let persistentStore: PersistentStoreType = PersistentStoreSelector.defaultPersistentStore
    
    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
        super.init()
    }
    
    override var executionQueue: Queue {
        return .main
    }
    
    override func execute() -> OperationResult<Void> {
        let defaults = NSUserDefaults.standardUserDefaults()
        let accountIdentifier: String? = defaults.stringForKey(kAccountIdentifierDefaultsKey)
        
        let storedLogin = VStoredLogin()
        if let info = storedLogin.storedLoginInfo() {
            let user = User(id: info.userRemoteId.integerValue)
            VCurrentUser.update(to: user)
            VCurrentUser.loginType = info.lastLoginType
            VCurrentUser.token = info.token
            
            guard
                let apiPath = dependencyManager.networkResources?.userFetchAPIPath,
                let userInfoOperation = UserInfoOperation(userID: user.id, apiPath: apiPath)
            else {
                let error = NSError(domain: "StoredLoginOperation-BadUserFetchAPIPath", code: -1, userInfo: ["DependencyManager": dependencyManager])
                Log.warning("Unable to initialize first user info fetch during StoredLoginOperation with error: \(error)")
                return .failure(error)
            }
            
            userInfoOperation.after(self).queue { _, error, _ in
                guard let user = userInfoOperation.user else {
                    Log.warning("User info fetch failed with error: \(error)")
                    return
                }
                VCurrentUser.update(to: user)
            }
            
        } else if let loginType = VLoginType(rawValue: defaults.integerForKey(kLastLoginTypeUserDefaultsKey)),
            let credentials = loginType.storedCredentials( accountIdentifier ) {
            
            // Next, if login with a stored token failed, use any stored credentials to login automatically
            let accountCreateRequest = AccountCreateRequest(credentials: credentials)
            let accountCreateOperation = AccountCreateOperation(
                dependencyManager: dependencyManager,
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
        
        return .success()
    }
}
