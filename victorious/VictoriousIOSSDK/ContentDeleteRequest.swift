//
//  ContentDeleteRequest.swift
//  victorious
//
//  Created by Vincent Ho on 6/10/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

public struct ContentDeleteRequest: RequestType {
    public var urlRequest: NSURLRequest {
        let request = NSMutableURLRequest(URL: contentDeleteURL)
        request.HTTPMethod = "POST"
        request.vsdk_addURLEncodedFormPost(["sequence_id": contentID])
        return request
    }
    
    private let contentDeleteURL: NSURL
    private let contentID: String
    
    public init?(contentID: String, contentDeleteURL: String) {
        self.contentID = contentID
        let replacementDictionary: [String: String] = ["%%CONTENT_ID%%": contentID]
        let replacedURL = VSDKURLMacroReplacement().urlByReplacingMacrosFromDictionary(replacementDictionary, inURLString: contentDeleteURL)
        guard let validURL = NSURL(string: replacedURL) else {
            return nil
        }
        self.contentDeleteURL = validURL
    }
}
