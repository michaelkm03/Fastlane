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
    public let userID: Int
    public let email: String?
    public let name: String?
    public let status: ProfileStatus?
    public let location: String?
    public let tagline: String?
    public let fanLoyalty: FanLoyalty?
    public let isCreator: Bool?
    public let isDirectMessagingDisabled: Bool?
    public let isFollowedByMainUser: Bool?
    public let numberOfFollowers: Int?
    public let numberOfFollowing: Int?
    public let profileImageURL: String?
    public let tokenUpdatedAt: NSDate?
    public let previewImageAssets: [ImageAsset]?
    public let maxVideoUploadDuration: Int?
}

extension User {
    public init?(json: JSON) {
        let userIDFromJSON: Int
        let dateFormatter = NSDateFormatter( format: DateFormat.Standard )
        
        // Check for "id" as either a string or a number, because the back-end is inconsistent.
        if let userIDString = json["id"].string,
           let userIDNumber = Int(userIDString) {
            userIDFromJSON = userIDNumber
        } else if let userIDValue = json["id"].int {
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
        isDirectMessagingDisabled   = json["is_direct_message_disabled"].bool
        isFollowedByMainUser        = json["am_following"].bool ?? false
        numberOfFollowers           = Int(json["number_of_followers"].stringValue)
        numberOfFollowing           = Int(json["number_of_following"].stringValue)
        profileImageURL             = json["profile_image"].string
        maxVideoUploadDuration      = Int(json["max_video_duration"].stringValue)
        
        if let dateString = json["token_updated_at"].string {
            self.tokenUpdatedAt = dateFormatter.dateFromString(dateString)
        } else {
            self.tokenUpdatedAt = nil
        }
    
        if let previewImageAssets = json["preview"]["assets"].array {
            self.previewImageAssets = previewImageAssets.flatMap { ImageAsset(json: $0) }
        } else {
            self.previewImageAssets = nil
        }
    }
}
