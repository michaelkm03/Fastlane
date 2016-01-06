//
//  FollowCountRequest.swift
//  victorious
//
//  Created by Tian Lan on 11/16/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct FollowCountRequest: RequestType {
    public let userID: Int
    
    public init (userID: Int) {
        self.userID = userID
    }
    
    public var urlRequest: NSURLRequest {
        return NSURLRequest(URL: NSURL(string: "/api/follow/counts/\(userID)")!)
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> FollowCount {
        guard let followingCount = Int(responseJSON["payload"]["subscribed_to"].stringValue),
            let followersCount = Int(responseJSON["payload"]["followers"].stringValue) else {
                throw ResponseParsingError()
        }
        return FollowCount(followingCount: followingCount, followersCount: followersCount)
    }
}

public struct FollowCount {
    public let followingCount: Int
    public let followersCount: Int
}
