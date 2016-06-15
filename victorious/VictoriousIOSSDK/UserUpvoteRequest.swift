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
        // FUTURE: Possibly remove based on backend API change
        request.vsdk_addURLEncodedFormPost(["user_id": userID])
        return request
    }
    
    private let userUpvoteURL: NSURL
    private let userID: String
  
    public init?(userID: Int, userUpvoteURL: String) {
        self.userID = String(userID)
        let replacementDictionary: [String: String] = ["%%USER_ID%%": self.userID]
        let replacedURL = VSDKURLMacroReplacement().urlByReplacingMacrosFromDictionary(replacementDictionary, inURLString: userUpvoteURL)
        guard let validURL = NSURL(string: replacedURL) else {
            return nil
        }
        self.userUpvoteURL = validURL
    }
}
