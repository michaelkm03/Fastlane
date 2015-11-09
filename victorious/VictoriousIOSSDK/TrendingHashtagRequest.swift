//
//  TrendingHashtagRequest.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct TrendingHashtagRequest: RequestType {
    
    public init() {}
    
    public var urlRequest: NSURLRequest {
        let url = NSURL(string: "/api/discover/hashtags")!
        let request = NSMutableURLRequest(URL: url)
        return request
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> [Hashtag] {
        return try HashtagResponseParser().parseResponse(responseJSON)
    }
}
