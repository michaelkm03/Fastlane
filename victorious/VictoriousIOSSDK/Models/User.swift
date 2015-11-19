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
    public let email: String?
    public let name: String?
    public let status: ProfileStatus
    public let location: String?
    public let tagline: String?
    public let fanLoyalty: FanLoyalty?
    public let isCreator: Bool
    public let isDirectMessagingDisabled: Bool
    public let isFollowedByMainUser: Bool
    public let numberOfFollowers: Int64
    public let numberOfFollowing: Int64
    public let profileImageURL: String
    public let tokenUpdatedAt: NSDate?
    public let previewImageAssets: [ImageAsset]
    public let maxVideoUploadDuration: Int64
}

extension User {
    public init?(json: JSON) {
        let userIDFromJSON: Int64
        let dateFormatter = NSDateFormatter( format: DateFormat.Standard )
        
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
            self.userID = userIDFromJSON
            self.status = status
        } else {
            return nil
        }
        
        email                       = json["email"].string
        name                        = json["name"].string
        location                    = json["profile_location"].string
        tagline                     = json["profile_tagline"].string
        fanLoyalty                  = FanLoyalty(json: json["fanloyalty"])
        isCreator                   = json["isCreator"].bool ?? false
        isDirectMessagingDisabled   = json["is_direct_message_disabled"].bool ?? false
        isFollowedByMainUser        = json["am_following"].bool ?? false
        numberOfFollowers           = Int64(json["number_of_followers"].stringValue) ?? 0
        numberOfFollowing           = Int64(json["number_of_following"].stringValue) ?? 0
        profileImageURL             = json["profile_image"].string ?? ""
        tokenUpdatedAt              = dateFormatter.dateFromString(json["token_updated_at"].stringValue)
        previewImageAssets          = json["preview"]["assets"].arrayValue.flatMap { ImageAsset(json: $0) }
        maxVideoUploadDuration      = Int64(json["max_video_duration"].stringValue) ?? 0
    }
}
