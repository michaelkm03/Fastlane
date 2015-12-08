//
//  FollowHashtagRequest.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct FollowHashtagRequest: RequestType {
    
    public let hashtagToFollow: String
    
    public init(hashtagToFollow: String) {
        self.hashtagToFollow = hashtagToFollow
    }
    
    public var urlRequest: NSURLRequest {
        let url = NSURL(string: "/api/hashtag/follow")!
        let request = NSMutableURLRequest(URL: url)
        let params = [ "hashtag": hashtagToFollow ]
        request.vsdk_addURLEncodedFormPost(params)
        return request
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> Int64 {
        
        guard let followRelationshipID = responseJSON["payload"]["followtag_id"].int64 else {
            throw ResponseParsingError()
        }
        
        return followRelationshipID
    }
}
