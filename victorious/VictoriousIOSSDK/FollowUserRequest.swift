//
//  FollowUsersRequest.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Follow a user
public struct FollowUserRequest: RequestType {
    
    /// The ID of the user you'd like to follow
    public let userID: Int64
    
    // The name of the screen from which you're following this user
    public let screenName: String
    
    public init(userID: Int64, screenName: String) {
        self.userID = userID
        self.screenName = screenName
    }
    
    public var urlRequest: NSURLRequest {
        let url = NSURL(string: "/api/follow/add")!
        let request = NSMutableURLRequest(URL: url)
        let params = [ "source": screenName, "target_user_id": String(userID) ]
        request.vsdk_addURLEncodedFormPost(params)
        return request
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws {
    }
}
