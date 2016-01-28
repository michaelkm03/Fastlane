//
//  DevicePreferencesRequest.swift
//  victorious
//
//  Created by Josh Hinman on 11/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct NotificationPreference: OptionSetType, Hashable {
    public let rawValue: Int
    private let stringValue: String
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
        self.stringValue = ""
    }
    
    private init(rawValue: Int, stringValue: String) {
        self.rawValue = rawValue
        self.stringValue = stringValue
    }
    
    public var hashValue: Int {
        return rawValue
    }
    
    // When new preferences are added to this list, make sure to also add them to the "all" collection!
    public static let CreatorPost       = NotificationPreference(rawValue: 1 << 0,  stringValue: "notification_creator_post")
    public static let FollowPost        = NotificationPreference(rawValue: 1 << 1,  stringValue: "notification_follow_post")
    public static let CommentPost       = NotificationPreference(rawValue: 1 << 2,  stringValue: "notification_comment_post")
    public static let PrivateMessage    = NotificationPreference(rawValue: 1 << 3,  stringValue: "notification_private_message")
    public static let NewFollower       = NotificationPreference(rawValue: 1 << 4,  stringValue: "notification_new_follower")
    public static let TagPost           = NotificationPreference(rawValue: 1 << 5,  stringValue: "notification_tag_post")
    public static let Mention           = NotificationPreference(rawValue: 1 << 6,  stringValue: "notification_mention")
    public static let LikePost          = NotificationPreference(rawValue: 1 << 7,  stringValue: "notification_like_post")
    public static let Announcement      = NotificationPreference(rawValue: 1 << 8,  stringValue: "notification_announcement")
    public static let NextDay           = NotificationPreference(rawValue: 1 << 9,  stringValue: "notification_next_day")
    public static let LapsedUser        = NotificationPreference(rawValue: 1 << 10, stringValue: "notification_lapsed_user")
    public static let EmotiveBallistic  = NotificationPreference(rawValue: 1 << 11, stringValue: "notification_emotive_ballistic")
    
    public static let all = [CreatorPost, FollowPost, CommentPost, PrivateMessage, NewFollower, TagPost, Mention, LikePost, Announcement, NextDay, LapsedUser, EmotiveBallistic]
}

public struct DevicePreferencesRequest: RequestType {
    
    private let url = NSURL(string: "/api/device/preferences")!
    
    /// The value that this endpoint considers "true"
    private let trueValue = "1"
    
    /// The value that this endpoint considers "false"
    private let falseValue = "0"
    
    private let preferences: [NotificationPreference: Bool]?
    
    public var urlRequest: NSURLRequest {
        let mutableURLRequest = NSMutableURLRequest(URL: url)
        if let preferences = self.preferences {
            var formpost: [String: String] = [:]
            for preference in NotificationPreference.all {
                if let shouldEnable = preferences[preference] {
                    formpost[preference.stringValue] = shouldEnable ? trueValue : falseValue
                }
            }
            mutableURLRequest.vsdk_addURLEncodedFormPost(formpost)
        }
        return mutableURLRequest
    }
    
    /// Use this initializer to retrieve the current list of preferences without making any changes
    public init() {
        self.preferences = nil
    }
    
    /// Use this initializer to change the values of these preferences for the current user.
    public init(preferences: [NotificationPreference: Bool]) {
        self.preferences = preferences
    }
    
    private func preferencesFromJSON(json: JSON) -> NotificationPreference {
        var returnValue: NotificationPreference = []
        for preference in NotificationPreference.all {
            if json[preference.stringValue].stringValue == trueValue {
                returnValue.insert(preference)
            }
        }
        return returnValue
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> NotificationPreference {
        let payload = responseJSON["payload"]
        return preferencesFromJSON(payload)
    }
}
