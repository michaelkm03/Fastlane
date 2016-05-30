//
//  TutorialContentsRequest.swift
//  victorious
//
//  Created by Tian Lan on 5/6/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Netowrk request to fetch an array of content which will be displayed as tutorial messages
public struct TutorialContentsRequest: TemplateDrivenRequestType {
    
    public private(set) var urlString: String
    
    public init(urlString: String) {
        self.urlString = urlString
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> [Content] {
        guard let json = responseJSON["payload"]["viewed_contents"].array else {
            throw ResponseParsingError()
        }
        
        return json.flatMap { Content(json: $0) }
    }
}
