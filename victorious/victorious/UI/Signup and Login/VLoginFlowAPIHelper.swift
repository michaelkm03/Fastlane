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
    func queueUpdateProfileOperation(displayname displayname: String?, profileImageURL: NSURL?, completion: ((NSError?) -> ())?) -> NSOperation? {
        let updateOperation = AccountUpdateOperation(
            profileUpdate: ProfileUpdate(
                displayName: displayname,
                location: nil,
                tagline: nil,
                profileImageURL: profileImageURL
            )
        )
        
        if let operation = updateOperation {
            operation.queue() { results, error, cancelled in
                completion?( error )
            }
            return operation
        }
        
        return nil
    }
    
    func queueFacebookLoginOperationWithCompletion(completion: (NSError?) -> ()) -> NSOperation {
        let loginType = VLoginType.Facebook
        let credentials: NewAccountCredentials = loginType.storedCredentials()!
        let accountCreateRequest = AccountCreateRequest(credentials: credentials)
        let operation = AccountCreateOperation(
            dependencyManager: dependencyManager,
            request: accountCreateRequest,
            parameters: AccountCreateParameters(
                loginType: loginType,
                accountIdentifier: nil
            )
        )
        operation.queue() { results, error, cancelled in
            completion(error)
        }
        return operation
    }
    
    func queueLoginOperationWithEmail(email: String, password: String, completion: ([AnyObject]?, NSError?, Bool) -> () ) -> NSOperation {
        let operation = LoginOperation(
            dependencyManager: dependencyManager,
            email: email,
            password: password
        )
        
        operation.queue( completion: completion )
        return operation
    }
    
    func queueAccountCreateOperationWithEmail(email: String, password: String, completion: ([AnyObject]?, NSError?, Bool) -> () ) -> NSOperation {
        let accountCreateRequest = AccountCreateRequest(credentials: .UsernamePassword(username: email, password: password))
        let operation = AccountCreateOperation(
            dependencyManager: dependencyManager,
            request: accountCreateRequest,
            parameters: AccountCreateParameters(
                loginType: .Email,
                accountIdentifier: email
            )
        )
        operation.queue(completion: completion)
        return operation
    }
}
