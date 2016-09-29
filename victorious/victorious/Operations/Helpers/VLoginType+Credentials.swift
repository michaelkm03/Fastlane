//
//  VLoginType+Credentials.swift
//  victorious
//
//  Created by Patrick Lynch on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK
import FBSDKCoreKit
import FBSDKLoginKit

extension VLoginType {
    func storedCredentials(_ accountIdentifier: String? = nil) -> NewAccountCredentials? {
        switch self {
            
        case .facebook:
            guard let currentToken = FBSDKAccessToken.current()
                , currentToken.expirationDate.timeIntervalSinceNow > 0.0 else {
                    return nil
            }
            return .Facebook(accessToken: currentToken.tokenString)
            
        case .email:
            guard
                let username = accountIdentifier,
                let password = VStoredPassword().password(forUsername: username)
            else {
                return nil
            }
            
            return .UsernamePassword(username: username, password: password)
            
        default:
            return nil
        }
    }
}
