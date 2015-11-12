//
//  BatchFollowUsersRequest.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Follow multiple users
public struct BatchFollowUsersRequest: RequestType {
    
    /// The IDs of the users you'd like to follow
    public let usersToFollow: [Int64]
    
    public init(usersToFollow: [Int64]) {
        self.usersToFollow = usersToFollow
    }
    
    public var urlRequest: NSURLRequest {
        let url = NSURL(string: "/api/follow/batchadd")!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        let converted = NSDictionary(dictionary: ["target_user_ids" : usersToFollow.map { NSNumber(longLong: $0) }])
        request.vsdk_addURLEncodedFormPost(converted)
        return request
    }
}
