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
public struct CreatorListRequest: TemplateDrivenRequestType {
    
    public private(set) var urlString: String
    
    public init(urlString: String) {
        self.urlString = urlString
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> [User] {
        guard let json = responseJSON["payload"]["users"].array else {
            throw ResponseParsingError()
        }
        
        return json.flatMap { User(json: $0) }
    }
}
