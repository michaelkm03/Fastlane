//
//  DeeplinkContext.swift
//  victorious
//
//  Created by Mariana Lenetis on 9/12/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

/// A struct used for passing the context(origin) information. Currently used for tracking
/// Properties: value - the context tag expected by the analytics team. This value can be one of the constants, or come from the template in some cases.
struct DeeplinkContext {
    static let closeupView = "closeup_view"
    static let userProfile = "user_profile"
    static let mainFeed = "main_feed"
    static let hashTagFeed = "hashtag_feed"
    static let chatRoomFeed = "chat_room_feed"

    fileprivate(set) var value: String?

    /// Initializer
    /// - paramenter value: the context
    /// - paramenter subContext: additional information appended to the context. eg: hashtag_feed#yay
    init(value: String?, subContext: String? = nil) {
        if value == "favorite.stream" {
            self.value = "bumped_feed"
        } else if value == "home.stream" {
            self.value = "main_feed"
        } else {
            self.value = value
        }

        if let value = value,
            let subContext = subContext {
            self.value = "\(value)\(subContext)"
        }
    }
}
