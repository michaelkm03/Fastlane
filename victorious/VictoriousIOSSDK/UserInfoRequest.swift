//
//  UserInfoRequest.swift
//  victorious
//
//  Created by Patrick Lynch on 11/13/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public struct UserInfoRequest: RequestType {
    private let url: NSURL
    
    public init?(apiPath: APIPath, userID: User.ID) {
        var apiPath = apiPath
        apiPath.macroReplacements["%%USER_ID%%"] = String(userID)
        
        guard let url = apiPath.url else {
            return nil
        }
        
        self.url = url
    }
    
    public var urlRequest: NSURLRequest {
        return NSURLRequest(URL: url)
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> User {
        guard let user = User(json: responseJSON["payload"]) else {
            throw ResponseParsingError()
        }
        return user
    }
}
