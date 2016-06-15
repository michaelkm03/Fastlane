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
    
    public init?(userID: Int, userBlockURL: String) {
        self.userID = String(userID)
        let replacementDictionary: [String: String] = ["%%USER_ID%%": self.userID]
        let replacedURL = VSDKURLMacroReplacement().urlByReplacingMacrosFromDictionary(replacementDictionary, inURLString: userBlockURL)
        guard let validURL = NSURL(string: replacedURL) else {
            return nil
        }
        self.userBlockURL = validURL
    }
}
