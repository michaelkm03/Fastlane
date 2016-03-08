//
//  FollowHashtagRequest.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public struct FollowHashtagRequest: RequestType {
    
    public let hashtag: String
    
    public init(hashtag: String) {
        self.hashtag = hashtag
    }
    
    public var urlRequest: NSURLRequest {
        let url = NSURL(string: "/api/hashtag/follow")!
        let request = NSMutableURLRequest(URL: url)
        let params = [ "hashtag" : hashtag ]
        request.vsdk_addURLEncodedFormPost(params)
        return request
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws {
    }
}
