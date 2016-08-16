//
//  AccountUpdateOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/20/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class AccountUpdateOperation: RemoteFetcherOperation, RequestOperation {
    private let storedPassword = VStoredPassword()
    
    let request: AccountUpdateRequest!
    
    init?(passwordUpdate: PasswordUpdate) {
        self.request = AccountUpdateRequest(passwordUpdate: passwordUpdate)
        super.init()
        if self.request == nil {
            return nil
        }
    }
    
    init?(profileUpdate: ProfileUpdate) {
        self.request = AccountUpdateRequest(profileUpdate: profileUpdate)
        super.init()
        if self.request == nil {
            return nil
        }
    }
    
    override func main() {
        // For profile updates, optimistically update everything right away
        if let profileUpdate = self.request.profileUpdate {
            persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
                guard let user = VCurrentUser.user(inManagedObjectContext: context) else {
                    self.error = NSError(domain: "AccountUpdateOperation", code: -1, userInfo: nil)
                    return
                }
                
                // Update basic stats
                user.displayName = profileUpdate.displayName ?? user.displayName
                user.location = profileUpdate.location ?? user.location
                user.tagline = profileUpdate.tagline ?? user.tagline
                
                // Update profile image
                if let imageURL = profileUpdate.profileImageURL {
                    if let data = NSData(contentsOfURL: imageURL),
                        let image = UIImage(data: data) {
                            let imageAsset: VImageAsset = context.v_createObject()
                            imageAsset.imageURL = imageURL.absoluteString
                            imageAsset.width = image.size.width
                            imageAsset.height = image.size.height
                            user.previewAssets = [imageAsset]
                    }
                }
                context.v_save()
            }
        }
        
        // Then send out the request the server
        requestExecutor.executeRequest(request, onComplete: onComplete, onError: nil)
    }
    
    private func onComplete(sequence: AccountUpdateRequest.ResultType) {
        if let passwordUpdate = request.passwordUpdate {
            storedPassword.savePassword(passwordUpdate.newPassword, forUsername: passwordUpdate.username)
        }
    }
}
