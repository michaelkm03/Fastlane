//
//  UnfollowHashtagRequest.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

/// Unfollow a hashtag
public struct UnfollowHashtagRequest: RequestType {
    
    /// The hashtag you'd like to unfollow
    public let hashtag: String
    
    public init(hashtag: String) {
        self.hashtag = hashtag
    }
    
    public var urlRequest: NSURLRequest {
        let url = NSURL(string: "/api/hashtag/unfollow")!
        let request = NSMutableURLRequest(URL: url)
        let params = [ "hashtag": hashtag ]
        request.vsdk_addURLEncodedFormPost(params)
        return request
    }
}
