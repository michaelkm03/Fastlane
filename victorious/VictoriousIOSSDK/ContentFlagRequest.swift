//
//  ContentFlagRequest.swift
//  victorious
//
//  Created by Vincent Ho on 5/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public struct ContentFlagRequest: RequestType {
    public var urlRequest: NSURLRequest {
        let request = NSMutableURLRequest(URL: contentFlagURL)
        request.HTTPMethod = "POST"
        return request
    }
    
    private let contentFlagURL: NSURL

    public init?(contentID: String, contentFlagURL: String) {
        let replacementDictionary: [String: String] = ["%%CONTENT_ID%%": contentID]
        let replacedURL = VSDKURLMacroReplacement().urlByReplacingMacrosFromDictionary(replacementDictionary, inURLString: contentFlagURL)
        guard let validURL = NSURL(string: replacedURL) else {
            return nil
        }
        self.contentFlagURL = validURL
    }
}
