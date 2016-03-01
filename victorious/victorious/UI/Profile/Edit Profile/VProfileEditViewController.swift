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
        let updateOperation = AccountUpdateOperation(
            profileUpdate: ProfileUpdate(
                email: nil,
                name: name,
                location: location,
                tagline: tagline,
                profileImageURL: profileImageURL
            )
        )
        
        if let operation = updateOperation {
            operation.queue()
            return operation
        }
        
        return nil
    }
}
