//
//  LoginSuccessOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 2/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// An operation that should be run after creating an account or logging in to set up and persist the current user's
/// information.
class LoginSuccessOperation: SyncOperation<Void> {
    
    // MARK: - Initializing
    
    init(dependencyManager: VDependencyManager, response: AccountCreateResponse, parameters: AccountCreateParameters) {
        self.dependencyManager = dependencyManager
        self.response = response
        self.parameters = parameters
    }
    
    // MARK: - Executing
    
    private let dependencyManager: VDependencyManager
    let parameters: AccountCreateParameters
    let response: AccountCreateResponse
    
    override var executionQueue: Queue {
        return .main
    }
    
    override func execute() -> OperationResult<Void> {
        let currentUser = response.user
            
        VCurrentUser.loginType = parameters.loginType
        VCurrentUser.token = response.token
        VCurrentUser.accountIdentifier = parameters.accountIdentifier
        VCurrentUser.isNewUser = response.newUser
        VCurrentUser.update(to: currentUser)
        
        updateStoredCredentials(currentUser)
        VLoginType(rawValue: parameters.loginType.rawValue)?.trackSuccess(VCurrentUser.isNewUser?.boolValue ?? false)
        return .success()
    }
    
    private func updateStoredCredentials(user: User) {
        guard let id = VCurrentUser.userID, let token = VCurrentUser.token else {
            return
        }
        
        let info = VStoredLoginInfo(id, withToken: token, withLoginType: VCurrentUser.loginType)
        
        VStoredLogin().saveLoggedInUserToDisk(info)
        
        NSUserDefaults.standardUserDefaults().setInteger(VCurrentUser.loginType.rawValue, forKey: kLastLoginTypeUserDefaultsKey)
        
        if let accountIdentifier = VCurrentUser.accountIdentifier {
            NSUserDefaults.standardUserDefaults().setObject( accountIdentifier, forKey: kAccountIdentifierDefaultsKey)
        }
    }
}
