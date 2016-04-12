//
//  VProfileCreateViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 11/20/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension VProfileCreateViewController {
    
    func queueUpdateProfileOperation( username username: String?, profileImageURL: NSURL?, location: String?, completion: ((NSError?) -> ())? ) -> NSOperation? {
        
        let updateOperation = AccountUpdateOperation(
            profileUpdate: ProfileUpdate(
                email: nil,
                name: username,
                location: location,
                tagline: nil,
                profileImageURL: profileImageURL
            )
        )
        
        if let operation = updateOperation {
            operation.queue() { (results, error) in
                completion?( error )
            }
            return operation
        }
        
        return nil
    }
}
