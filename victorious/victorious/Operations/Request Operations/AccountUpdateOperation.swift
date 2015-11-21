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
    private let profileUpdate: User.ProfileUpdate?
    private let passwordUpdate: User.PasswordUpdate?
    
    init(passwordUpdate: User.PasswordUpdate) {
        self.profileUpdate = nil
        self.passwordUpdate = passwordUpdate
        super.init( request: AccountUpdateRequest(passwordUpdate: passwordUpdate)! )
    }
    
    init(profileUpdate: User.ProfileUpdate) {
        self.profileUpdate = profileUpdate
        self.passwordUpdate = nil
        super.init( request: AccountUpdateRequest(profileUpdate: profileUpdate)! )
    }
    
    override func onStart( completion:()->() ) {
        
        // For profile updates, optimistically update everything right away
        if let profileUpdate = self.profileUpdate {
            persistentStore.asyncFromBackground() { context in
                guard let user = VUser.currentUser() else {
                    fatalError( "Expecting a current user to be set before now." )
                }
                user.name = profileUpdate.name ?? user.name
                user.email = profileUpdate.email ?? user.email
                user.location = profileUpdate.location ?? user.location
                user.tagline = profileUpdate.tagline ?? user.tagline
                context.saveChanges()
                completion()
            }
        }
        else {
            completion()
        }
    }
    
    override func onComplete( response: AccountUpdateRequest.ResultType, completion:()->() ) {
        
        if let passwordUpdate = self.passwordUpdate {
            self.storedPassword.savePassword(passwordUpdate.passwordNew, forEmail: passwordUpdate.email)
        }
        
        let user = response
        
        // Update current user based on response from endpoint
        persistentStore.asyncFromBackground() { context in
            guard let persistentUser = VUser.currentUser() else {
                fatalError( "Could not locate current user." )
            }
            persistentUser.populate(fromSourceModel: user)
            context.saveChanges()
            completion()
        }
    }
}