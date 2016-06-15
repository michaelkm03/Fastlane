//
//  UserUnblockRequest.swift
//  victorious
//
//  Created by Vincent Ho on 6/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public struct UserUnblockRequest: RequestType {
    public var urlRequest: NSURLRequest {
        let request = NSMutableURLRequest(URL: userUnblockURL)
        request.HTTPMethod = "POST"
        request.vsdk_addURLEncodedFormPost(["user_id": userID])
        return request
    }
    
    private let userUnblockURL: NSURL
    private let userID: String
    
    public init?(userID: Int, userUnblockURL: String) {
        self.userID = String(userID)
        let replacementDictionary: [String: String] = ["%%USER_ID%%": self.userID]
        let replacedURL = VSDKURLMacroReplacement().urlByReplacingMacrosFromDictionary(replacementDictionary, inURLString: userUnblockURL)
        guard let validURL = NSURL(string: replacedURL) else {
            return nil
        }
        self.userUnblockURL = validURL
    }
}
