//
//  User.swift
//  VictoriousIOSSDK
//
//  Created by Josh Hinman on 10/24/15.
//  Copyright © 2015 Victorious, Inc. All rights reserved.
//

import SwiftyJSON

/// The status of a user's profile information
public enum ProfileStatus: String {
    /// We have enough information about this user
    case Complete = "complete"
    
    /// We're missing something required in this user's profile
    case Incomplete = "incomplete"
}

/// A struct representing a user's information
public struct User {
    public let userID: Int64
    public var email: String?
    public var name: String?
    public var status: ProfileStatus
    public var location: String?
    public var tagline: String?
    public var avatar: [ImageAsset]
    public var fanLoyalty: FanLoyalty?
    public var numberOfFollowers: Int64?
    
    public init(userID: Int64, status: ProfileStatus)
    {
        self.userID = userID
        self.status = status
        avatar = []
    }
}

extension User {
    public init?(json: JSON) {
        let userIDFromJSON: Int64
        
        // Check for "id" as either a string or a number, because the back-end is inconsistent.
        if let userIDString = json["id"].string,
           let userIDNumber = Int64(userIDString) {
            userIDFromJSON = userIDNumber
        } else if let userIDValue = json["id"].int64 {
            userIDFromJSON = userIDValue
        } else {
            return nil
        }
        
        if let statusString = json["status"].string,
           let status = ProfileStatus(rawValue: statusString) {
            self.init(userID: userIDFromJSON, status: status)
        } else {
            return nil
        }
        
        email = json["email"].string
        name = json["name"].string
        location = json["profile_location"].string
        tagline = json["profile_tagline"].string
        
        if let previewAssetsArray = json["preview"]["assets"].array {
            avatar = previewAssetsArray.flatMap { ImageAsset(json: $0) }
        }
        
        let fanLoyaltyJSON = json["fanloyalty"]
        if let fanLoyaltyStats = FanLoyalty(json: fanLoyaltyJSON) {
            fanLoyalty = fanLoyaltyStats
        }
        
        if let numFollowersString = json["number_of_followers"].string {
            numberOfFollowers = Int64(numFollowersString)
        }
    }
}
