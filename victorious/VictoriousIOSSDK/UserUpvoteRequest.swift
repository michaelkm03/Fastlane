//
//  UserUpvoteRequest.swift
//  victorious
//
//  Created by Vincent Ho on 6/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public struct UserUpvoteRequest: RequestType {
    public var urlRequest: NSURLRequest {
        let request = NSMutableURLRequest(URL: userUpvoteURL)
        request.HTTPMethod = "POST"
        request.vsdk_addURLEncodedFormPost(["target_user_id": userID])
        return request
    }
    
    private let userUpvoteURL: NSURL
    private let userID: String
  
    public init?(userID: Int, userUpvoteAPIPath: APIPath) {
        var userUpvoteAPIPath = userUpvoteAPIPath
        self.userID = String(userID)
        
        userUpvoteAPIPath.macroReplacements["%%USER_ID%%"] = self.userID
        guard let validURL = userUpvoteAPIPath.url else {
            return nil
        }
        self.userUpvoteURL = validURL
    }
}
