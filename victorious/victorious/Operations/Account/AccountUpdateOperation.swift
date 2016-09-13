//
//  AccountUpdateOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/20/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class AccountUpdateOperation: SyncOperation<Void> {
    
    // MARK: - Initializing
    
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
    
    // MARK: - Executing
    
    private let request: AccountUpdateRequest!
    
    override var executionQueue: Queue {
        return .main
    }
    
    override func execute() -> OperationResult<Void> {
        // For profile updates, optimistically update everything right away
        if let profileUpdate = request.profileUpdate {
            guard var user = VCurrentUser.user else {
                return .failure(NSError(domain: "AccountUpdateOperation", code: -1, userInfo: nil))
            }
            
            // Update basic stats
            user.displayName = profileUpdate.displayName ?? user.displayName
            user.location = profileUpdate.location ?? user.location
            user.tagline = profileUpdate.tagline ?? user.tagline
            
            // Update profile image
            if
                let imageURL = profileUpdate.profileImageURL,
                let data = NSData(contentsOfURL: imageURL),
                let image = UIImage(data: data)
            {
                let imageAsset = ImageAsset(image: image)
                user.previewImages = [imageAsset]
            }
            
            VCurrentUser.update(to: user)
        }
        
        // Then send out the request the server
        RequestOperation(request: request).queue { [weak self] _ in
            if let passwordUpdate = self?.request.passwordUpdate {
                VStoredPassword().savePassword(passwordUpdate.newPassword, forUsername: passwordUpdate.username)
            }
        }
        
        return .success()
    }
}
