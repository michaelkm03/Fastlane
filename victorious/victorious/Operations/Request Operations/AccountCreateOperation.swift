//
//  AccountCreateOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class AccountCreateOperation: RequestOperation {
    
    private let loginType: VLoginType
    private let accountIdentifier: String?
    
    let request: AccountCreateRequest
    
    var isNewUser = false
    
    init( request: AccountCreateRequest, loginType: VLoginType, accountIdentifier: String? = nil ) {
        self.loginType = loginType
        self.accountIdentifier = accountIdentifier
        self.request = request
    }
    
    // MARK: - Operation overrides
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: onComplete, onError: nil )
    }
    
    func onComplete( response: AccountCreateResponse, completion:()->() ) {
        self.isNewUser = response.newUser
        
        storedBackgroundContext = persistentStore.createBackgroundContext().v_performBlock() { context in
            
            // First, find or create the new user who just logged in
            let user: VUser = context.v_findOrCreateObject( [ "remoteId" : response.user.userID ])
            user.populate(fromSourceModel: response.user)
            user.loginType = self.loginType.rawValue
            user.token = response.token
            
            // Save, merging the changes into the main context
            context.v_save()
            
            // After saving, the objectID is available
            let userObjectID = user.objectID
            
            self.persistentStore.mainContext.v_performBlock() { context in
                
                // Reload from main context to continue login process
                guard let user = context.objectWithID(userObjectID) as? VUser else {
                    assertionFailure( "Cannot retrieve user by objectID." )
                    return
                }
                user.setAsCurrentUser()
                self.updateStoredCredentials( user )
                VLoginType(rawValue: user.loginType.integerValue)?.trackSuccess( self.isNewUser )
                PreloadUserInfoOperation().queueAfter(self)
                completion()
            }
        }
    }
    
    private func updateStoredCredentials( user: VUser ) {
        VStoredLogin().saveLoggedInUserToDisk( user )
        NSUserDefaults.standardUserDefaults().setInteger( user.loginType.integerValue, forKey: kLastLoginTypeUserDefaultsKey)
        if let accountIdentifier = self.accountIdentifier {
            NSUserDefaults.standardUserDefaults().setObject( accountIdentifier, forKey: kAccountIdentifierDefaultsKey)
        }
    }
}
