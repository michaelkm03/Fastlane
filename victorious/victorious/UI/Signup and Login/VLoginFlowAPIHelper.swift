//
//  VLoginFlowAPIHelper.swift
//  victorious
//
//  Created by Patrick Lynch on 11/12/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension VLoginFlowAPIHelper {
    
    func queueLoginOperationWithEmail(email: String, password: String, completion:(NSError?)->() ) -> NSOperation {
        let accountCreateRequest = AccountCreateRequest(credentials: .EmailPassword(email: email, password: password))
        let operation = AccountCreateOperation( request: accountCreateRequest, loginType: .Email, accountIdentifier: email )
        operation.queue( completion )
        return operation
    }
    
    func queueUpdateProfileOperation( username username: String?, profileImageURL: NSURL?, completion: ((NSError?)->())? ) -> NSOperation? {
        let updateOperation = AccountUpdateOperation(
            profileUpdate: ProfileUpdate(
                email: nil,
                name: username,
                location: nil,
                tagline: nil,
                profileImageURL: profileImageURL
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
    
    func queueRequestPasswordResetOperation(email: String, completion:(NSError?)->Void) -> NSOperation {
        let operation = RequestPasswordResetOperation(email: email)
        operation.queue(completion)
        
        return operation
    }
}
