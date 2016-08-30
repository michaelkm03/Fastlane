//
//  LoginSuccessOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 2/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class LoginSuccessOperation: FetcherOperation {
    
    private let dependencyManager: VDependencyManager
    let parameters: AccountCreateParameters
    let response: AccountCreateResponse
    
    private var userObjectID: NSManagedObjectID?
    
    init(dependencyManager: VDependencyManager, response: AccountCreateResponse, parameters: AccountCreateParameters) {
        self.dependencyManager = dependencyManager
        self.response = response
        self.parameters = parameters
    }
    
    override func main() {
        guard !cancelled else {
            return
        }
        
        let currentUser = self.response.user
            
        VCurrentUser.loginType = self.parameters.loginType.rawValue
        VCurrentUser.token = self.response.token
        VCurrentUser.accountIdentifier = self.parameters.accountIdentifier
        VCurrentUser.isNewUser = self.response.newUser
        
        dispatch_sync(dispatch_get_main_queue()) {
            VCurrentUser.update(to: currentUser)
        }
        
        self.updateStoredCredentials(currentUser)
        VLoginType(rawValue: self.parameters.loginType.rawValue)?.trackSuccess(VCurrentUser.isNewUser?.boolValue ?? false)
    }
    
    private func updateStoredCredentials( user: User ) {
        VStoredLogin().saveLoggedInUserToDisk()
        if let loginTypeValue = VCurrentUser.loginType?.integerValue {
            NSUserDefaults.standardUserDefaults().setInteger(loginTypeValue, forKey: kLastLoginTypeUserDefaultsKey)
        }
        if let accountIdentifier = VCurrentUser.accountIdentifier {
            NSUserDefaults.standardUserDefaults().setObject( accountIdentifier, forKey: kAccountIdentifierDefaultsKey)
        }
    }
}
