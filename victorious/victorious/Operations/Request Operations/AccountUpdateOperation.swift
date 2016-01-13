//
//  AccountUpdateOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/20/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class AccountUpdateOperation: RequestOperation {
    
    private let storedPassword = VStoredPassword()
    
    let request: AccountUpdateRequest
    private(set) var results: [AnyObject]?
    private(set) var didResetResults: Bool = false
    
    required init( request: AccountUpdateRequest ) {
        self.request = request
    }
    
    convenience init?( passwordUpdate: PasswordUpdate ) {
        if let request = AccountUpdateRequest(passwordUpdate: passwordUpdate) {
            self.init(request: request)
        } else {
            return nil
        }
    }
    
    convenience init?( profileUpdate: ProfileUpdate ) {
        if let request = AccountUpdateRequest(profileUpdate: profileUpdate) {
            self.init(request: request)
        } else {
            return nil
        }
    }
    
    override func main() {
        
        // For profile updates, optimistically update everything right away
        if let profileUpdate = self.request.profileUpdate {
            persistentStore.createBackgroundContext().v_performBlockAndWait() { context in

                guard let user = VCurrentUser.user() else {
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
                            let imageAsset: VImageAsset = context.v_createObject()
                            imageAsset.imageURL = imageURL.absoluteString
                            imageAsset.width = image.size.width
                            imageAsset.height = image.size.height
                            imageAsset.type = "image/jpeg"
                            user.previewAssets = Set<NSObject>()
                            user.previewAssets.insert( imageAsset )
                    }
                }
                context.v_save()
            }
        }
        
        // Then send out the request the server
        requestExecutor.executeRequest( request, onComplete: onComplete, onError: nil )
    }
    
    private func onComplete( sequence: AccountUpdateRequest.ResultType, completion:()->() ) {
        if let passwordUpdate = self.request.passwordUpdate {
            self.storedPassword.savePassword( passwordUpdate.passwordNew, forEmail: passwordUpdate.email )
        }
        completion()
    }
}
