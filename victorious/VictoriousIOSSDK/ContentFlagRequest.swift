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
        let replacementDictionary: [String: String] = [ "%%CONTENT_ID%%": contentID]
        let replacedURL = VSDKURLMacroReplacement().urlByReplacingMacrosFromDictionary(replacementDictionary, inURLString: contentFlagURL)
        let request = NSMutableURLRequest(URL: NSURL(string: replacedURL)!)
        return request
    }
    
    private let contentID: String
    private let contentFlagURL: String

    public init(contentID: String, contentFlagURL: String) {
        self.contentID = contentID
        self.contentFlagURL = contentFlagURL
    }
}
