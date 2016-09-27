//
//  PasswordResetRequest.swift
//  victorious
//
//  Created by Tian Lan on 1/6/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public struct PasswordResetRequest: RequestType {
    
    public let newPassword: String
    public let userToken: String
    public let deviceToken: String
    
    /// Optional parameter `newPassword`: Pass nil to validate the tokens.
    /// Pass a valid String value to reset password.
    public init(newPassword: String = "", userToken: String, deviceToken: String) {
        self.newPassword = newPassword
        self.userToken = userToken
        self.deviceToken = deviceToken
    }
    
    public var urlRequest: NSURLRequest {
        
        let urlRequest = NSMutableURLRequest(url: NSURL(string: "/api/password_reset")! as URL)
        let passwordResetInfo = [
            "new_password": newPassword,
            "user_token": userToken,
            "device_token": deviceToken
        ]
        urlRequest.vsdk_addURLEncodedFormPost(passwordResetInfo)
        
        return urlRequest
    }
}
