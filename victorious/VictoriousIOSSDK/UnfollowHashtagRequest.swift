//
//  UnfollowHashtagRequest.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Unfollow a hashtag
public struct UnfollowHashtagRequest: RequestType {
    
    /// The hashtag you'd like to unfollow
    public let hashtagToUnfollow: String
    
    public init(hashtagToUnfollow: String) {
        self.hashtagToUnfollow = hashtagToUnfollow
    }
    
    public var urlRequest: NSURLRequest {
        let url = NSURL(string: "/api/hashtag/unfollow")!
        let request = NSMutableURLRequest(URL: url)
        let params = [ "hashtag": hashtagToUnfollow ]
        request.vsdk_addURLEncodedFormPost(params)
        return request
    }
}
