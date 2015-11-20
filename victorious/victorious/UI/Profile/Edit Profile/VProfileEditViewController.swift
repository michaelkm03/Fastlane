//
//  VEditProfileViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 11/20/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import UIKit
import VictoriousIOSSDK

extension VProfileEditViewController {
    
    func updateProfile( name name: String?, profileImageURL: NSURL?, location: String?, tagline: String?, completion: ((NSError?)->())? ) -> NSOperation? {
        let operation = AccountUpdateOperation(
            profileUpdate: User.ProfileUpdate(
                email: VUser.currentUser()!.email!,
                name: name,
                location: location,
                tagline: tagline,
                profileImageURL: profileImageURL
            )
        )
        operation.queue() { error in
            completion?( error )
        }
        return operation
    }
}