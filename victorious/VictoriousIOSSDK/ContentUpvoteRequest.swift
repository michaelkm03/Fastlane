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
        let replacementDictionary: [String: String] = [ "%%CONTENT_ID%%": contentID]
        let replacedURL = VSDKURLMacroReplacement().urlByReplacingMacrosFromDictionary(replacementDictionary, inURLString: contentUpvoteURL)
        let request = NSMutableURLRequest(URL: NSURL(string: replacedURL)!)
        return request
    }
    
    private let contentID: String
    private let contentUpvoteURL: String
    
    public init(contentID: String, contentUpvoteURL: String) {
        self.contentID = contentID
        self.contentUpvoteURL = contentUpvoteURL
    }
}
