//
//  LoginRequest.swift
//  victorious
//
//  Created by Josh Hinman on 11/6/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public struct LoginRequest: RequestType {
    public let email: String
    public let password: String

    public var urlRequest: URLRequest {
        var urlRequest = URLRequest(url: URL(string: "/api/login")!)
        urlRequest.httpMethod = "POST"
        urlRequest.vsdk_addURLEncodedFormPost([ "email": email, "password": password ])
        return urlRequest
    }
    
    public init(email: String, password: String) {
        self.email = email
        self.password = password
    }
    
    public func parseResponse(_ response: URLResponse, toRequest request: URLRequest, responseData: Data, responseJSON: JSON) throws -> AccountCreateResponse {
        let payload = responseJSON["payload"]
        if let token = payload["token"].string,
           let user = User(json: payload) {
                return AccountCreateResponse(token: token, user: user)
        }
        throw ResponseParsingError()
    }
}
