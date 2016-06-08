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
        
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            
            // First, find or create the new user who just logged in
            let user: VUser = context.v_findOrCreateObject([ "remoteId" : self.response.user.id ])
            user.populate(fromSourceModel: self.response.user)
            user.loginType = self.parameters.loginType.rawValue
            user.token = self.response.token
            user.accountIdentifier = self.parameters.accountIdentifier
            user.isNewUser = self.response.newUser
            
            context.v_save()
            
            // After saving, the objectID is available
            self.userObjectID = user.objectID
            PreloadUserInfoOperation(dependencyManager: self.dependencyManager).after(self).queue()
        }
        
        persistentStore.mainContext.v_performBlockAndWait() { context in
            
            // Reload from main context to continue login process
            guard let userObjectID = self.userObjectID, let user = context.objectWithID(userObjectID) as? VUser else {
                assertionFailure( "Cannot retrieve user by objectID." )
                return
            }
            
            user.setAsCurrentUser()
            self.updateStoredCredentials( user )
            VLoginType(rawValue: user.loginType.integerValue)?.trackSuccess( user.isNewUser?.boolValue ?? false )
        }
    }
    
    private func updateStoredCredentials( user: VUser ) {
        VStoredLogin().saveLoggedInUserToDisk( user )
        NSUserDefaults.standardUserDefaults().setInteger( user.loginType.integerValue, forKey: kLastLoginTypeUserDefaultsKey)
        if let accountIdentifier = user.accountIdentifier {
            NSUserDefaults.standardUserDefaults().setObject( accountIdentifier, forKey: kAccountIdentifierDefaultsKey)
        }
    }
}
