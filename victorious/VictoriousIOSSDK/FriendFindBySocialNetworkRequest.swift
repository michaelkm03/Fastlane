//
//  FriendFindBySocialNetworkRequest.swift
//  victorious
//
//  Created by Tian Lan on 2/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public enum FriendFindBySocialNetworkCredentials {
    case Facebook(accessToken: String)
}

public struct FriendFindBySocialNetworkRequest: RequestType {
    
    public let socialNetwork: FriendFindBySocialNetworkCredentials
    
    public init(socialNetwork: FriendFindBySocialNetworkCredentials) {
        self.socialNetwork = socialNetwork
    }
    
    public var urlRequest: NSURLRequest {
        let baseURL = NSURL(string: "/api/friend/find")!
        let fullURL = socialNetwork.urlForSocialNetworkFromURL(baseURL)
        return NSURLRequest(URL: fullURL)
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> [User] {
        let foundUsersJSON = responseJSON["payload"].arrayValue
        
        return foundUsersJSON.flatMap { User(json: $0) }
    }
}

private extension FriendFindBySocialNetworkCredentials {
    
    func urlForSocialNetworkFromURL(url: NSURL) -> NSURL {
        var output = url
        switch self {
        case let .Facebook(token):
            output = output.URLByAppendingPathComponent("facebook")
            output = output.URLByAppendingPathComponent(token)
        }
        return output
    }
}
