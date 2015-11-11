//
//  DevicePreferencesRequest.swift
//  victorious
//
//  Created by Josh Hinman on 11/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct NotificationPreference: OptionSetType {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let CreatorPost = NotificationPreference(rawValue: 1 << 0)
    public static let FollowPost = NotificationPreference(rawValue: 1 << 1)
    public static let CommentPost = NotificationPreference(rawValue: 1 << 2)
    public static let PrivateMessage = NotificationPreference(rawValue: 1 << 3)
    public static let NewFollower = NotificationPreference(rawValue: 1 << 4)
    public static let TagPost = NotificationPreference(rawValue: 1 << 5)
    public static let Mention = NotificationPreference(rawValue: 1 << 6)
    public static let LikePost = NotificationPreference(rawValue: 1 << 7)
    public static let Announcement = NotificationPreference(rawValue: 1 << 8)
    public static let NextDay = NotificationPreference(rawValue: 1 << 9)
    public static let LapsedUser = NotificationPreference(rawValue: 1 << 10)
    public static let EmotiveBallistic = NotificationPreference(rawValue: 1 << 11)
}

public struct DevicePreferencesRequest: RequestType {
    public let urlRequest: NSURLRequest
    
    public init() {
        urlRequest = NSURLRequest(URL: NSURL(string: "/api/device/preferences")!)
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> NotificationPreference {
        let affirmativeValue = "1"
        let payload = responseJSON["payload"]
        var preferences: NotificationPreference = []
        
        if payload["notification_creator_post"].stringValue == affirmativeValue {
            preferences.insert(.CreatorPost)
        }
        if payload["notification_follow_post"].stringValue == affirmativeValue {
            preferences.insert(.FollowPost)
        }
        if payload["notification_comment_post"].stringValue == affirmativeValue {
            preferences.insert(.CommentPost)
        }
        if payload["notification_private_message"].stringValue == affirmativeValue {
            preferences.insert(.PrivateMessage)
        }
        if payload["notification_new_follower"].stringValue == affirmativeValue {
            preferences.insert(.NewFollower)
        }
        if payload["notification_tag_post"].stringValue == affirmativeValue {
            preferences.insert(.TagPost)
        }
        if payload["notification_mention"].stringValue == affirmativeValue {
            preferences.insert(.Mention)
        }
        if payload["notification_like_post"].stringValue == affirmativeValue {
            preferences.insert(.LikePost)
        }
        if payload["notification_announcement"].stringValue == affirmativeValue {
            preferences.insert(.Announcement)
        }
        if payload["notification_next_day"].stringValue == affirmativeValue {
            preferences.insert(.NextDay)
        }
        if payload["notification_lapsed_user"].stringValue == affirmativeValue {
            preferences.insert(.LapsedUser)
        }
        if payload["notification_emotive_ballistic"].stringValue == affirmativeValue {
            preferences.insert(.EmotiveBallistic)
        }
        
        return preferences
    }
}
