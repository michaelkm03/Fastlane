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
    
    private static func defaultURL(forUserID userID: Int) -> NSURL {
         return NSURL(string: "/api/userinfo/fetch")!.URLByAppendingPathComponent(String(userID))
    }
    
    public init(userID: Int, apiPath: String? = nil) {
        let url: NSURL
        
        if let apiPath = apiPath {
            let macroReplacer = VSDKURLMacroReplacement()
            
            let processedAPIPath = macroReplacer.urlByReplacingMacrosFromDictionary([
                "%%USER_ID%%": String(userID)
            ], inURLString: apiPath)
            
            url = NSURL(string: processedAPIPath) ?? UserInfoRequest.defaultURL(forUserID: userID)
        } else {
            url = UserInfoRequest.defaultURL(forUserID: userID)
        }
        
        urlRequest = NSURLRequest(URL: url)
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> User {
        let results = responseJSON["payload"].arrayValue.flatMap({ User(json: $0) })
        if let user = results.first {
            return user
        }
        throw ResponseParsingError()
    }
}
