//
//  AccountCreateRequest.swift
//  VictoriousIOSSDK
//
//  Created by Josh Hinman on 10/24/15.
//  Copyright © 2015 Victorious, Inc. All rights reserved.
//

/// The different ways a new account can be established at Victorious
public enum NewAccountCredentials {
    /// An account based on a username and password combination
    case UsernamePassword(username: String, password: String)
    
    /// An account based on a Facebook oauth token
    case Facebook(accessToken: String)
}

/// The endpoint that creates a new account, or logs into an existing social (Facebook) account.
///
/// Path: /api/account/create
public struct AccountCreateRequest: RequestType {
    /// The credentials that will be used to create a new account
    public let credentials: NewAccountCredentials
    
    public var urlRequest: URLRequest {
        var urlRequest = URLRequest(url: AccountCreateRequest.basePath)
        urlRequest.httpMethod = "POST"
        
        switch credentials {
            case let .UsernamePassword(username, password):
                urlRequest.vsdk_addURLEncodedFormPost(["email": username, "password": password])
            
            case let .Facebook(accessToken):
                urlRequest.url = urlRequest.url?.appendingPathComponent("via_facebook_modern")
                urlRequest.vsdk_addURLEncodedFormPost(["facebook_access_token": accessToken])
        }
        
        return urlRequest
    }
    
    public init(credentials: NewAccountCredentials) {
        self.credentials = credentials
    }
    
    public func parseResponse(_ response: URLResponse, toRequest request: URLRequest, responseData: Data, responseJSON: JSON) throws -> AccountCreateResponse {
        let payload = responseJSON["payload"]
        if let token = payload["token"].string,
           let user = User(json: payload) {
            return AccountCreateResponse(token: token, user: user, newUser: payload["new_user"].bool ?? true)
        }
        throw ResponseParsingError()
    }
    
    private static let basePath = URL(string: "/api/account/create")!
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
    
    public init( token: String, user: User, newUser: Bool = false ) {
        self.token = token
        self.user = user
        self.newUser = newUser
    }
}
