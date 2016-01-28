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
        let updateOperation = AccountUpdateOperation(
            passwordUpdate: PasswordUpdate(
                email: VCurrentUser.user()!.email!,
                passwordCurrent: current,
                passwordNew: new
            )
        )
        
        if let operation = updateOperation {
            operation.queue() { error in
                completion?( error )
            }
            return operation
        }
        
        return nil
    }
}