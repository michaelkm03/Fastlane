//
//  UserUnupvoteRequest.swift
//  victorious
//
//  Created by Vincent Ho on 6/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public struct UserUnupvoteRequest: RequestType {
    public var urlRequest: NSURLRequest {
        let request = NSMutableURLRequest(URL: userUnupvoteURL)
        request.HTTPMethod = "POST"
        request.vsdk_addURLEncodedFormPost(["target_user_id": userID])
        return request
    }
    
    private let userUnupvoteURL: NSURL
    private let userID: String
    
    public init?(userID: Int, userUnupvoteURL: String) {
        self.userID = String(userID)
        let replacementDictionary: [String: String] = ["%%USER_ID%%": self.userID]
        let replacedURL = VSDKURLMacroReplacement().urlByReplacingMacrosFromDictionary(replacementDictionary, inURLString: userUnupvoteURL)
        guard let validURL = NSURL(string: replacedURL) else {
            return nil
        }
        self.userUnupvoteURL = validURL
    }
}
