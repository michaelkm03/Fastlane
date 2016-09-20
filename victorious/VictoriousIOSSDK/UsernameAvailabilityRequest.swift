//
//  UsernameAvailabilityRequest.swift
//  victorious
//
//  Created by Michael Sena on 9/20/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public struct UsernameAvailabilityRequest: RequestType {
    
    private let url: NSURL
    private let usernameToCheck: String
    
    public init?(apiPath: APIPath, usernameToCheck: String) {
        guard let url = apiPath.url else {
            return nil
        }
        
        self.url = url
        self.usernameToCheck = usernameToCheck
    }
    
    public var urlRequest: NSURLRequest {
        return NSURLRequest(URL: self.url)
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> Bool {
        let json = responseJSON["payload"]
        //TODO: Implement me properly
        return true
    }
}
