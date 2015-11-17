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
    public let userID: Int64
    
    public init (userID: Int64) {
        self.userID = userID
    }
    
    public var urlRequest: NSURLRequest {
        return NSURLRequest(URL: NSURL(string: "/api/follow/counts/\(userID)")!)
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> FollowCount? {
        return FollowCount(json: responseJSON)
    }
}
