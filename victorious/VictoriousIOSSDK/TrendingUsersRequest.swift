//
//  TrendingUsersRequest.swift
//  victorious
//
//  Created by Tian Lan on 1/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public struct TrendingUsersRequest: RequestType {
    
    public init() {}
    
    public var urlRequest: NSURLRequest {
        let url = NSURL(string: "/api/discover/users")!
        let request = NSURLRequest(URL: url)
        return request
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> [User]{
        guard let json = responseJSON["payload"].array else {
            throw ResponseParsingError()
        }
        
        return json.flatMap() { User(json: $0) }
    }
}
