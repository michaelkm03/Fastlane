//
//  ContentUnupvoteRequest.swift
//  victorious
//
//  Created by Vincent Ho on 5/31/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public struct ContentUnupvoteRequest: RequestType {
    public var urlRequest: NSURLRequest {
        let request = NSMutableURLRequest(URL: contentUnupvoteURL)
        request.HTTPMethod = "POST"
        return request
    }
    
    private let contentUnupvoteURL: NSURL
    
    public init?(contentID: String, contentUnupvoteURL: String) {
        let replacementDictionary: [String: String] = ["%%CONTENT_ID%%": contentID]
        let replacedURL = VSDKURLMacroReplacement().urlByReplacingMacrosFromDictionary(replacementDictionary, inURLString: contentUnupvoteURL)
        guard let validURL = NSURL(string: replacedURL) else {
            return nil
        }
        self.contentUnupvoteURL = validURL
    }
}
