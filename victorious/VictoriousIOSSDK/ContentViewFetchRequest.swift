//
//  ContentViewFetchRequest.swift
//  victorious
//
//  Created by Sebastian Nystorm on 25/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public struct ContentViewFetchRequest : RequestType {
    private let urlMacroExpander = VSDKURLMacroReplacement()
    
    private let contentID: String
    private let currentUserID: String
    private let url: NSURL
    
    public init?(macroURLString: String, currentUserID: String, contentID: String) {
        let replacementDictionary: [NSObject : AnyObject] = ["%%SEQUENCE_ID%%": contentID, "%%USER_ID%%": currentUserID]
        let urlString = urlMacroExpander.urlByReplacingMacrosFromDictionary(replacementDictionary, inURLString: macroURLString)
        
        guard let url = NSURL(string: urlString) else {
            return nil
        }
        
        self.url = url
        self.currentUserID = currentUserID
        self.contentID = contentID
    }
    
    public var baseUrl: NSURL? {
        return url.baseURL
    }
    
    public var urlRequest: NSURLRequest {
        return NSMutableURLRequest(URL: url)
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> ContentView {
        guard let contentView = ContentView(json: responseJSON) else {
            throw ResponseParsingError()
        }
        return contentView
    }
}
