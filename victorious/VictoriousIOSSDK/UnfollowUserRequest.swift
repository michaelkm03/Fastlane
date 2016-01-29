//
//  UnfollowUserRequest.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Unfollow a user
public struct UnfollowUserRequest: RequestType {
    
    /// The ID of the user you'd like to unfollow
    public let userID: Int

    /// The name of the screen from which you're unfollowing this user
    public let sourceScreenName: String?
    
    public init(userID: Int, sourceScreenName: String?) {
        self.userID = userID
        self.sourceScreenName = sourceScreenName
    }
    
    public var urlRequest: NSURLRequest {
        let url = NSURL(string: "/api/follow/remove")!
        let request = NSMutableURLRequest(URL: url)
        let params = [ "source": sourceScreenName ?? "", "target_user_id": String(userID) ]
        request.vsdk_addURLEncodedFormPost(params)
        return request
    }
}
