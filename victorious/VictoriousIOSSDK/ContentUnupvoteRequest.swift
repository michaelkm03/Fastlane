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
        let replacementDictionary: [String: String] = [ "%%CONTENT_ID%%": contentID]
        let replacedURL = VSDKURLMacroReplacement().urlByReplacingMacrosFromDictionary(replacementDictionary, inURLString: contentUnupvoteURL)
        let request = NSMutableURLRequest(URL: NSURL(string: replacedURL)!)
        return request
    }
    
    private let contentID: String
    private let contentUnupvoteURL: String
    
    public init(contentID: String, contentUnupvoteURL: String) {
        self.contentID = contentID
        self.contentUnupvoteURL = contentUnupvoteURL
    }
}
