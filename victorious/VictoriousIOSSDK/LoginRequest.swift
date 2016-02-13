//
//  LoginRequest.swift
//  victorious
//
//  Created by Josh Hinman on 11/6/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct LoginRequest: RequestType {
    public let email: String
    public let password: String

    public var urlRequest: NSURLRequest {
        let urlRequest = NSMutableURLRequest(URL: NSURL(string: "/api/login")!)
        urlRequest.HTTPMethod = "POST"
        urlRequest.vsdk_addURLEncodedFormPost([ "email": email, "password": password ])
        return urlRequest
    }
    
    public init(email: String, password: String) {
        self.email = email
        self.password = password
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> LoginResponse {
        let payload = responseJSON["payload"]
        if let token = payload["token"].string,
           let user = User(json: payload) {
                return LoginResponse(token: token, user: user)
        }
        throw ResponseParsingError()
    }
}

/// The response to a login call
public struct LoginResponse {
    /// Authentication token for the new account
    public let token: String
    
    /// Details on the new account
    public let user: User
    
    public init(token: String, user: User) {
        self.token = token
        self.user = user
    }
}
