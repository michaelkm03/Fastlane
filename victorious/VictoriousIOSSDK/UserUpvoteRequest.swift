//
//  UserUpvoteRequest.swift
//  victorious
//
//  Created by Vincent Ho on 6/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public struct UserUpvoteRequest: RequestType {
    private let url: NSURL
    private let userID: User.ID
    
    public init?(apiPath: APIPath, userID: User.ID) {
        var apiPath = apiPath
        apiPath.macroReplacements["%%USER_ID%%"] = String(userID)
        
        guard let validURL = apiPath.url else {
            return nil
        }
        
        self.url = validURL
        self.userID = userID
    }
    
    public var urlRequest: NSURLRequest {
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.vsdk_addURLEncodedFormPost(["target_user_id": String(userID)])
        return request
    }
}
