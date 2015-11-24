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
    
    private let persistentStore: PersistentStoreType = MainPersistentStore()
    
    private let storedPassword = VStoredPassword()
    private let profileUpdate: ProfileUpdate?
    private let passwordUpdate: PasswordUpdate?
    
    init(passwordUpdate: PasswordUpdate) {
        self.profileUpdate = nil
        self.passwordUpdate = passwordUpdate
        super.init( request: AccountUpdateRequest(passwordUpdate: passwordUpdate)! )
    }
    
    init(profileUpdate: ProfileUpdate) {
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
                
                // Update basic stats
                user.name = profileUpdate.name ?? user.name
                user.email = profileUpdate.email ?? user.email
                user.location = profileUpdate.location ?? user.location
                user.tagline = profileUpdate.tagline ?? user.tagline
                
                // Update profile image
                if let imageURL = profileUpdate.profileImageURL {
                    user.pictureUrl = imageURL.absoluteString
                    if let data = NSData(contentsOfURL: imageURL),
                        let image = UIImage(data: data) {
                            let imageAsset: VImageAsset = context.createObject()
                            imageAsset.imageURL = imageURL.absoluteString
                            imageAsset.width = image.size.width
                            imageAsset.height = image.size.height
                            imageAsset.type = "image/jpeg"
                            user.previewAssets = Set<NSObject>()
                            user.previewAssets.insert( imageAsset )
                    }
                }
                
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
    }
}