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
    func queueUpdateProfileOperation(displayname: String?, profileImageURL: NSURL?, completion: ((NSError?) -> ())?) -> Operation? {
        let updateOperation = AccountUpdateOperation(
            profileUpdate: ProfileUpdate(
                displayName: displayname,
                username: nil,
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
    
    func queueFacebookLoginOperationWithCompletion(_ completion: @escaping (NSError?) -> ()) -> Operation {
        let loginType = VLoginType.facebook
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
    
    func queueLoginOperationWithEmail(_ email: String, password: String, completion: @escaping ([AnyObject]?, NSError?, Bool) -> () ) -> Operation {
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
    
    func queueAccountCreateOperationWithEmail(_ email: String, password: String, completion: @escaping ([AnyObject]?, NSError?, Bool) -> () ) -> Operation {
        let operation = AccountCreateOperation(
            dependencyManager: dependencyManager,
            credentials: .UsernamePassword(username: email, password: password),
            parameters: AccountCreateParameters(
                loginType: .email,
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
    
    func queueRequestPasswordResetOperationWithEmail(_ email: String, completion: @escaping (_ deviceToken: String?, _ error: NSError?) -> Void) -> Operation {
        let operation = RequestOperation(request: RequestPasswordResetRequest(email: email))
        
        operation.queue { result in
            switch result {
                case .success(let deviceToken): completion(deviceToken, nil)
                case .failure(let error): completion(nil, error as NSError)
                case .cancelled: completion(nil, nil)
            }
        }
        
        return operation
    }
    
    func queuePasswordResetOperationWithNewPassword
        (_ password: String, userToken: String, deviceToken: String, completion: @escaping (_ error: NSError?) -> Void) -> Operation {
        let operation = RequestOperation(
            request: PasswordResetRequest(newPassword: password, userToken: userToken, deviceToken: deviceToken)
        )
        
        operation.queue { result in
            switch result {
                case .success, .cancelled: completion(nil)
                case .failure(let error): completion(error as NSError)
            }
        }
        
        return operation
    }
    
    func queuePasswordResetOperationWithUserToken(_ userToken: String, deviceToken: String, completion: @escaping (_ error: NSError?) -> Void) -> Operation {
        return queuePasswordResetOperationWithNewPassword("", userToken: userToken, deviceToken: deviceToken, completion: completion)
    }
}
