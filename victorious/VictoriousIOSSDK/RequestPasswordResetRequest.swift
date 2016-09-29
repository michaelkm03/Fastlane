//
//  RequestPasswordResetRequest.swift
//  victorious
//
//  Created by Tian Lan on 1/6/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public struct RequestPasswordResetRequest: RequestType {
    
    public let email: String
    
    public init(email: String) {
        self.email = email
    }
    
    public var urlRequest: URLRequest {
        var urlRequest = URLRequest(url: URL(string: "/api/password_reset_request")!)
        let accountInfo = [ "email": email ]
        urlRequest.vsdk_addURLEncodedFormPost(accountInfo)
        
        return urlRequest
    }
    
    public func parseResponse(response: URLResponse, toRequest request: URLRequest, responseData: Data, responseJSON: JSON) throws -> String {
        let payload = responseJSON["payload"]
        guard let deviceToken = payload["device_token"].string else {
            throw ResponseParsingError()
        }
        
        return deviceToken
    }
}
