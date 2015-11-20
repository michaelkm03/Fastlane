//
//  AccountUpdateOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/20/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class AccountUpdateOperation: RequestOperation<AccountUpdateRequest> {
    
    private let persistentStore = PersistentStore()
    private let storedPassword = VStoredPassword()
    
    init(passwordUpdate: User.PasswordUpdate) {
        super.init( request: AccountUpdateRequest(passwordUpdate: passwordUpdate)! )
    }
    
    init(profileUpdate: User.ProfileUpdate) {
        super.init( request: AccountUpdateRequest(profileUpdate: profileUpdate)! )
    }
    
    override func onStart() {
        
        print( self.request.profileUpdate )
        
        // Optimistically update everything right away
        if let profileUpdate = self.request.profileUpdate {
            persistentStore.asyncFromBackground() { context in
                if let user = VUser.currentUser(inContext: context) {
                    user.name = profileUpdate.name ?? user.name
                    user.email = profileUpdate.email ?? user.email
                    user.location = profileUpdate.location ?? user.location
                    user.tagline = profileUpdate.tagline ?? user.tagline
                    context.saveChanges()
                }
            }
        }
    }
    
    override func onResponse(response: AccountUpdateRequest.ResultType) {
        guard let user = response else {
            fatalError( "Could not parse user from response." )
        }
        
        // Update current user based on response from endpoint
        persistentStore.asyncFromBackground() { context in
            guard let persistentUser = VUser.currentUser(inContext: context) else {
                fatalError( "Could not locate current user." )
            }
            persistentUser.populate(fromSourceModel: user)
        }
        
        if let passwordUpdate = self.request.passwordUpdate {
            dispatch_sync( dispatch_get_main_queue() ) {
                self.storedPassword.savePassword(passwordUpdate.passwordNew, forEmail: passwordUpdate.email)
            }
        }
    }
}