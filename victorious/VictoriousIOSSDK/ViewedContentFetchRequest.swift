//
//  ContentViewFetchRequest.swift
//  victorious
//
//  Created by Sebastian Nystorm on 25/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public struct ViewedContentFetchRequest : RequestType {
    private let urlMacroExpander = VSDKURLMacroReplacement()

    private let url: NSURL

    public init?(macroURLString: String, currentUserID: String, contentID: String) {
        let replacementDictionary: [NSObject : AnyObject] = ["%%CONTENT_ID%%": contentID, "%%USER_ID%%": currentUserID]
        let urlString = urlMacroExpander.urlByReplacingMacrosFromDictionary(replacementDictionary, inURLString: macroURLString)
        
        guard let url = NSURL(string: urlString) else {
            return nil
        }
        
        self.url = url
    }

    public var baseUrl: NSURL? {
        return url.baseURL
    }
    
    public var urlRequest: NSURLRequest {
        return NSMutableURLRequest(URL: url)
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> ViewedContent {
        guard let contentView = ViewedContent(json: responseJSON) else {
            throw ResponseParsingError()
        }
        return contentView
    }
}
