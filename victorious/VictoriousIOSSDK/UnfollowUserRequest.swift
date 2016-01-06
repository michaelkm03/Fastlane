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
    public let userID: Int64

    // The name of the screen from which you're unfollowing this user
    public let screenName: String
    
    public init(userID: Int64, screenName: String) {
        self.userID = userID
        self.screenName = screenName
    }
    
    public var urlRequest: NSURLRequest {
        let url = NSURL(string: "/api/follow/remove")!
        let request = NSMutableURLRequest(URL: url)
        let params = [ "source": screenName, "target_user_id": String(userID) ]
        request.vsdk_addURLEncodedFormPost(params)
        return request
    }
}
