//
//  ContentListFetchRequest.swift
//  victorious
//
//  Created by Jarod Long on 5/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public struct ContentListFetchRequest: TemplateDrivenRequestType {
    // MARK: - Initializing
    
    public init(urlString: String, fromTime: NSDate) {
        self.urlString = urlString
        self.fromTime = fromTime
    }
    
    // MARK: - URL
    
    public private(set) var urlString: String
    private let fromTime: NSDate
    
    public var macroReplacementDictionary: [String: String]? {
        let fromTimestamp = Int(fromTime.timeIntervalSince1970 * 1000.0)
        return ["%%FROM_TIME%%": String(fromTimestamp)]
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> [ViewedContent] {
        guard let contentJSONs = responseJSON["payload"]["viewed_contents"].array else {
            throw ResponseParsingError()
        }
        
        return contentJSONs.flatMap { ViewedContent(json: $0) }
    }
}
