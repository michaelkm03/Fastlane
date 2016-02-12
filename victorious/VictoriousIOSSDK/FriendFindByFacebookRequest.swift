//
//  FriendFindByFacebookRequest.swift
//  victorious
//
//  Created by Tian Lan on 2/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//


import Foundation

public typealias FriendFindSocialNetwork = NewAccountCredentials

public struct FriendFindByFacebookRequest {
    public let socialNetwork: FriendFindSocialNetwork
    
    public init(socialNetwork: FriendFindSocialNetwork) {
        self.socialNetwork = socialNetwork
    }
}
