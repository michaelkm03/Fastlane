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
            operation.queue { result in
                switch result {
                    case .success, .cancelled: completion?(nil)
                    case .failure(let error): completion?(error as NSError)
                }
            }
            
            return operation
        }
        
        return nil
    }
    
    func queueFacebookLoginOperationWithCompletion(completion: (NSError?) -> ()) -> NSOperation {
        let loginType = VLoginType.Facebook
        let credentials: NewAccountCredentials = loginType.storedCredentials()!
        let operation = AccountCreateOperation(
            dependencyManager: dependencyManager,
            credentials: credentials,
            parameters: AccountCreateParameters(
                loginType: loginType,
                accountIdentifier: nil
            )
        )
        operation.queue { result in
            switch result {
                case .success(_), .cancelled: completion(nil)
                case .failure(let error): completion(error as NSError)
            }
        }
        return operation
    }
    
    func queueLoginOperationWithEmail(email: String, password: String, completion: ([AnyObject]?, NSError?, Bool) -> () ) -> NSOperation {
        let operation = LoginOperation(
            dependencyManager: dependencyManager,
            email: email,
            password: password
        )
        
        operation.queue { result in
            switch result {
                case .success(_): completion(nil, nil, false)
                case .failure(let error): completion(nil, error as NSError, false)
                case .cancelled: completion(nil, nil, true)
            }
        }
        
        return operation
    }
    
    func queueAccountCreateOperationWithEmail(email: String, password: String, completion: ([AnyObject]?, NSError?, Bool) -> () ) -> NSOperation {
        let operation = AccountCreateOperation(
            dependencyManager: dependencyManager,
            credentials: .UsernamePassword(username: email, password: password),
            parameters: AccountCreateParameters(
                loginType: .Email,
                accountIdentifier: email
            )
        )
        
        operation.queue { result in
            switch result {
                case .success(_): completion(nil, nil, false)
                case .failure(let error): completion(nil, error as NSError, false)
                case .cancelled: completion(nil, nil, true)
            }
        }
        
        return operation
    }
    
    func queueRequestPasswordResetOperationWithEmail(email: String, completion: (deviceToken: String?, error: NSError?) -> Void) -> NSOperation {
        let operation = RequestOperation(request: RequestPasswordResetRequest(email: email))
        
        operation.queue { result in
            switch result {
                case .success(let deviceToken): completion(deviceToken: deviceToken, error: nil)
                case .failure(let error): completion(deviceToken: nil, error: error as NSError)
                case .cancelled: completion(deviceToken: nil, error: nil)
            }
        }
        
        return operation
    }
    
    func queuePasswordResetOperationWithNewPassword(password: String, userToken: String, deviceToken: String, completion: (error: NSError?) -> Void) -> NSOperation {
        let operation = RequestOperation(
            request: PasswordResetRequest(newPassword: password, userToken: userToken, deviceToken: deviceToken)
        )
        
        operation.queue { result in
            switch result {
                case .success, .cancelled: completion(error: nil)
                case .failure(let error): completion(error: error as NSError)
            }
        }
        
        return operation
    }
    
    func queuePasswordResetOperationWithUserToken(userToken: String, deviceToken: String, completion: (error: NSError?) -> Void) -> NSOperation {
        return queuePasswordResetOperationWithNewPassword("", userToken: userToken, deviceToken: deviceToken, completion: completion)
    }
}
