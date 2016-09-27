//
//  DeeplinkContext.swift
//  victorious
//
//  Created by Mariana Lenetis on 9/12/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation


/// A struct used for passing the context(origin) information. Currently used for tracking
/// Initializer: value - the context, subContext - additional information appended to the context. eg: hashtag_feed#yay
/// Properties: value - the context tag expected by the analytics team. This value can be one of the constants, or come from the template in some cases.

struct DeeplinkContext {
    static let closeupView = "closeup_view"
    static let userProfile = "user_profile"
    static let mainFeed = "main_feed"
    static let hashTagFeed = "hashtag_feed"
    static let chatRoomFeed = "chat_room_feed"

    private(set) var value: String?

    init(value: String?, subContext: String? = nil) {
        if value == "favorite.stream" {
            self.value = "bumped_feed"
        } else if value == "home.stream" {
            self.value = "main_feed"
        } else {
            self.value = value
        }

        if let value = value,
            subContext = subContext {
            self.value = "\(value)\(subContext)"
        }
    }
}