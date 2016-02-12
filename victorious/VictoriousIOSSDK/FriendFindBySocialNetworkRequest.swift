//
//  FriendFindBySocialNetworkRequest.swift
//  victorious
//
//  Created by Tian Lan on 2/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//


import Foundation
import SwiftyJSON

public enum FriendFindSocialNetwork {
    case Facebook(platformName: String, accessToken: String)
}

public struct FriendFindBySocialNetworkRequest: RequestType {
    public let socialNetwork: FriendFindSocialNetwork
    
    public init(socialNetwork: FriendFindSocialNetwork) {
        self.socialNetwork = socialNetwork
    }
    
    public var urlRequest: NSURLRequest {
        var url = NSURL(string: "/api/friend/find")
        
        switch socialNetwork {
        case let .Facebook(platform, token):
            url = url?.URLByAppendingPathComponent(platform)
            url = url?.URLByAppendingPathComponent(token)
        }
        
        return NSURLRequest(URL: url!)
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> [User] {
        let foundUsersJSON = responseJSON["payload"].arrayValue
        
        return foundUsersJSON.flatMap { User(json: $0) }
    }
    
}
