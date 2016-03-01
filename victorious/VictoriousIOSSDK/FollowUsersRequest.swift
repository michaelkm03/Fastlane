//
//  FollowUsersRequest.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public struct FollowUsersRequest: RequestType {
    
    public let userIDs: [Int]
    public let sourceScreenName: String
    
    public init(userIDs: [Int], sourceScreenName: String) {
        self.userIDs = userIDs
        self.sourceScreenName = sourceScreenName
    }
    
    public var urlRequest: NSURLRequest {
        if userIDs.isEmpty {
            fatalError( "At least one valid userID must be provided." )
        
        } else if userIDs.count == 1 {
            let url = NSURL(string: "/api/follow/add")!
            let request = NSMutableURLRequest(URL: url)
            let params = [ "source": sourceScreenName, "target_user_id": String( userIDs[0] ) ]
            request.vsdk_addURLEncodedFormPost(params)
            return request
        
        } else {
            let url = NSURL(string: "/api/follow/batchadd")!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            let converted = NSDictionary(dictionary: ["target_user_ids" : userIDs ] )
            request.vsdk_addURLEncodedFormPost(converted)
            return request
        }
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws {
    }
}
