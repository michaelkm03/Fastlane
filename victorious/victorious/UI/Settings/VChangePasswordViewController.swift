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
    
    func updatePassword( currentPassword current: String, newPassword new: String, completion: ((NSError?)->())? ) -> NSOperation? {
        let operation = AccountUpdateOperation(
            passwordUpdate: User.PasswordUpdate(
                email: VUser.currentUser()!.email!,
                passwordCurrent: current,
                passwordNew: new
            )
        )
        operation.queue() { error in
            completion?( error )
        }
        return operation
    }
}