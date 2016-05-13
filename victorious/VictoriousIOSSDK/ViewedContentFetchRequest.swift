//
//  ContentViewFetchRequest.swift
//  victorious
//
//  Created by Sebastian Nystorm on 25/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public struct ViewedContentFetchRequest : TemplateDrivenRequestType {
    
    public private(set) var urlString: String
    
    public var macroReplacementDictionary: [String : String]? {
        return ["%%CONTENT_ID%%": contentID, "%%USER_ID%%": currentUserID]
    }
    
    private let currentUserID: String
    private let contentID: String
    
    public init(macroURLString: String, currentUserID: String, contentID: String) {
        self.urlString = macroURLString
        self.currentUserID = currentUserID
        self.contentID = contentID
    }

    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> ViewedContent {
        
        let json = responseJSON["payload"]
        guard let contentView = ViewedContent(json: json) else {
            throw ResponseParsingError()
        }
        return contentView
    }
}
