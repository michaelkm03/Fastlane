//
//  UserBlockRequest.swift
//  victorious
//
//  Created by Vincent Ho on 6/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public struct UserBlockRequest: RequestType {
    public var urlRequest: NSURLRequest {
        let request = NSMutableURLRequest(URL: userBlockURL)
        request.HTTPMethod = "POST"
        request.vsdk_addURLEncodedFormPost(["user_id": userID])
        return request
    }
    
    private let userBlockURL: NSURL
    private let userID: String
    
    public init?(userID: Int, userBlockAPIPath: APIPath) {
        var userBlockAPIPath = userBlockAPIPath
        self.userID = String(userID)
        
        userBlockAPIPath.macroReplacements["%%USER_ID%%"] = self.userID
        guard let validURL = userBlockAPIPath.url else {
            return nil
        }
        self.userBlockURL = validURL
    }
}
