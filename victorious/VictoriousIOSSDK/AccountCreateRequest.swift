//
//  AccountCreateRequest.swift
//  VictoriousIOSSDK
//
//  Created by Josh Hinman on 10/24/15.
//  Copyright © 2015 Victorious, Inc. All rights reserved.
//

import SwiftyJSON

/// The different ways a new account can be established at Victorious
public enum NewAccountCredentials {
    /// An account based on an e-mail address and password combination
    case EmailPassword(email: String, password: String)
    
    /// An account based on a Facebook oauth token
    case Facebook(accessToken: String)
    
    /// An account based on a Twitter oauth token
    case Twitter(accessToken: String, accessSecret: String, twitterID: String)
}

/// The endpoint that creates a new account, or logs into an existing social (Facebook/Twitter) account.
///
/// Path: /api/account/create
public struct AccountCreateRequest: RequestType {
    /// The credentials that will be used to create a new account
    public let credentials: NewAccountCredentials
    
    public var urlRequest: NSURLRequest {
        let urlRequest = NSMutableURLRequest(URL: AccountCreateRequest.basePath)
        urlRequest.HTTPMethod = "POST"
        
        switch credentials {
        
        case let .EmailPassword(email, password):
            let credentials = [ "email": email,
                                "password": password ]
            urlRequest.vsdk_addURLEncodedFormPost(credentials)
            break
            
        case let .Facebook(accessToken):
            urlRequest.URL = urlRequest.URL?.URLByAppendingPathComponent("via_facebook_modern")
            let credentials = [ "facebook_access_token": accessToken ]
            urlRequest.vsdk_addURLEncodedFormPost(credentials)
            break
            
        case let .Twitter(accessToken, accessSecret, twitterID):
            urlRequest.URL = urlRequest.URL?.URLByAppendingPathComponent("via_twitter_modern")
            let credentials = [ "access_token": accessToken,
                                "access_secret": accessSecret,
                                "twitter_id": twitterID ]
            urlRequest.vsdk_addURLEncodedFormPost(credentials)
            break
        }
        return urlRequest
    }
    
    public init(credentials: NewAccountCredentials) {
        self.credentials = credentials
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> AccountCreateResponse {
        let payload = responseJSON["payload"]
        if let token = payload["token"].string,
           let user = User(json: payload) {
            return AccountCreateResponse(token: token, user: user, newUser: payload["new_user"].bool ?? true)
        }
        throw ResponseParsingError()
    }
    
    private static let basePath = NSURL(string: "/api/account/create")!
}

/// The response to an account create call
public struct AccountCreateResponse {
    /// Authentication token for the new account
    public let token: String
    
    /// Details on the new account
    public let user: User
    
    /// false if the credentials provided matched an existing 
    /// account, true if a truly new account was created.
    public let newUser: Bool
}
