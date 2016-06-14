//
//  UserInfoRequest.swift
//  victorious
//
//  Created by Patrick Lynch on 11/13/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public struct UserInfoRequest: RequestType {
    public let urlRequest: NSURLRequest
    
    public init?(userID: Int, apiPath: String) {
        let macroReplacer = VSDKURLMacroReplacement()
        
        let processedAPIPath = macroReplacer.urlByReplacingMacrosFromDictionary(
            ["%%USER_ID%%": String(userID)],
            inURLString: apiPath
        )
        
        guard let url = NSURL(string: processedAPIPath) else {
            return nil
        }
        
        urlRequest = NSURLRequest(URL: url)
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> User {
        guard let user = User(json: responseJSON["payload"]) else {
            throw ResponseParsingError()
        }
        return user
    }
}
