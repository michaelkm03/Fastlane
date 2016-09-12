//
//  CreatorListRequest.swift
//  victorious
//
//  Created by Tian Lan on 4/22/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// A network request to retrive the list of creators (API Owners)
/// Response of this request should be `[User]`
public struct CreatorListRequest: RequestType {
    public private(set) var apiPath: APIPath
    
    public init(apiPath: APIPath) {
        self.apiPath = apiPath
    }
    
    public var urlRequest: NSURLRequest {
        guard let url = apiPath.url else {
            Log.warning("Invalid API path provided to CreatorListRequest.")
            return NSURLRequest(URL: NSURL())
        }
        
        return NSURLRequest(URL: url)
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> [UserModel] {
        guard let json = responseJSON["payload"]["users"].array else {
            throw ResponseParsingError()
        }
        
        return json.flatMap { User(json: $0) }
    }
}
