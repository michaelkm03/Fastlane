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
    
    func updateProfile( name name: String?, profileImageURL: NSURL?, location: String?, tagline: String? ) -> NSOperation? {
        let operation = AccountUpdateOperation(
            profileUpdate: ProfileUpdate(
                email: VUser.currentUser()!.email!,
                name: name,
                location: location,
                tagline: tagline,
                profileImageURL: profileImageURL
            )
        )
        operation!.queue()
        return operation
    }
}