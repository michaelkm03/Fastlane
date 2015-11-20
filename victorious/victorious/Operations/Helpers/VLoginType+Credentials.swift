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
    
    func storedCredentials( accountIdentifier: String? = nil ) -> NewAccountCredentials? {
        switch self {
            
        case .Facebook:
            guard let currentToken = FBSDKAccessToken.currentAccessToken()
                where currentToken.expirationDate.timeIntervalSinceNow > 0.0 else {
                    return nil
            }
            return .Facebook(accessToken: currentToken.tokenString)
            
        case .Email:
            guard let email = accountIdentifier,
                let password = VStoredPassword().passwordForEmail( email ) else {
                    return nil
            }
            return .EmailPassword(email: email, password: password)
            
        default:
            return nil
        }
    }
}
