//
//  ContentUpvoteRequest.swift
//  victorious
//
//  Created by Vincent Ho on 5/31/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public struct ContentUpvoteRequest: RequestType {
    public var urlRequest: NSURLRequest {
        let request = NSMutableURLRequest(URL: contentUpvoteURL)
        request.HTTPMethod = "POST"
        return request
    }
    
    private let contentUpvoteURL: NSURL
    
    public init?(contentID: String, contentUpvoteURL: String) {
        let replacementDictionary: [String: String] = ["%%CONTENT_ID%%": contentID]
        let replacedURL = VSDKURLMacroReplacement().urlByReplacingMacrosFromDictionary(replacementDictionary, inURLString: contentUpvoteURL)
        guard let validURL = NSURL(string: replacedURL) else {
            return nil
        }
        self.contentUpvoteURL = validURL
    }
}
