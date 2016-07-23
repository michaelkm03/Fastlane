//
//  VChangePasswordViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 11/20/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import UIKit
import VictoriousIOSSDK

extension VChangePasswordViewController {
    func updatePassword(currentPassword: String, newPassword: String, completion: ((NSError?) -> Void)?) -> NSOperation? {
        guard let username = VCurrentUser.user()?.username else {
            return nil
        }
        
        let updateOperation = AccountUpdateOperation(
            passwordUpdate: PasswordUpdate(
                username: username,
                currentPassword: currentPassword,
                newPassword: newPassword
            )
        )
        
        if let operation = updateOperation {
            operation.queue { results, error, cancelled in
                completion?(error)
            }
            return operation
        }
        
        return nil
    }
}
