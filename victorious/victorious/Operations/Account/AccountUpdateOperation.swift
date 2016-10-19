//
//  AccountUpdateOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/20/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class AccountUpdateOperation: AsyncOperation <User> {
    
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
    
    override func execute(_ finish: @escaping (_ result: OperationResult<User>) -> Void) {
        RequestOperation(request: request).queue { [weak self] requestResult in
            guard let strongSelf = self else {
                finish(requestResult)
                return
            }
            if let passwordUpdate = self?.request.passwordUpdate {
                VStoredPassword().save(passwordUpdate.newPassword, forUsername: passwordUpdate.username)
            }
            switch requestResult {
                case .success:
                    if let profileUpdate = strongSelf.request.profileUpdate {
                        guard var user = VCurrentUser.user else {
                            finish(.failure(NSError(domain: "AccountUpdateOperation", code: -1, userInfo: nil)))
                            return
                        }
                        
                        // Update basic stats
                        user.displayName = profileUpdate.displayName ?? user.displayName
                        user.username = profileUpdate.username ?? user.username
                        user.location = profileUpdate.location ?? user.location
                        user.tagline = profileUpdate.tagline ?? user.tagline
                        
                        // Update profile image
                        if
                            let imageURL = profileUpdate.profileImageURL,
                            let data = NSData(contentsOf: imageURL as URL),
                            let image = UIImage(data: data as Data)
                        {
                            let imageAsset = ImageAsset(image: image)
                            user.previewImages = [imageAsset]
                        }
                        
                        VCurrentUser.update(to: user)
                    }
                    finish(requestResult)
                case .failure(let error): finish(.failure(error))
                case .cancelled: finish(.cancelled)
            }
        }
    }
}
