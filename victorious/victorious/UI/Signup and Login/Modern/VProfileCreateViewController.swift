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
    
    func queueLoginOperationWithEmail(email: String, password: String, completion:(NSError?)->() ) -> NSOperation {
        let accountCreateRequest = AccountCreateRequest(credentials: .EmailPassword(email: email, password: password))
        let operation = AccountCreateOperation( request: accountCreateRequest, loginType: .Email, accountIdentifier: email )
        operation.queue( completion )
        return operation
    }
    
    func queueUpdateProfileOperation( username username: String?, profileImageURL: NSURL?, location: String?, completion: ((NSError?)->())? ) -> NSOperation? {
        let operation = AccountUpdateOperation(
            profileUpdate: ProfileUpdate(
                email: nil,
                name: username,
                location: location,
                tagline: nil,
                profileImageURL: profileImageURL
            )
        )
        operation.queue() { error in
            completion?( error )
        }
        return operation
    }
}
