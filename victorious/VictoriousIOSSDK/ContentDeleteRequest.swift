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
        return request
    }
    
    private let contentDeleteURL: NSURL
    
    public init?(contentID: String, contentDeleteURL: String) {
        let replacementDictionary: [String: String] = ["%%CONTENT_ID%%": contentID]
        let replacedURL = VSDKURLMacroReplacement().urlByReplacingMacrosFromDictionary(replacementDictionary, inURLString: contentDeleteURL)
        guard let validURL = NSURL(string: replacedURL) else {
            return nil
        }
        self.contentDeleteURL = validURL
    }
}
