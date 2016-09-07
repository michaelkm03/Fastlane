//
//  DeeplinkContext.swift
//  victorious
//
//  Created by Mariana Lenetis on 9/2/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

// The source of the deeplink call

enum DeeplinkContext: String {
    case closeUpView = "closeup_view"
    case userProfile = "user_profile"
    case feed = "FEED"
    case bumpedFeed = "bumped_feed"
    case hashtagName = "hashtag_name"
    case mainFeed = "main_feed"
    case stage = "STAGE"
    case mainStage = "main_stage"
    case vipStage = "vip_stage"

    case grid = "GRID"
    case listMenu = "LISTMENU"
    case loginFlow = "LOGINFLOW"
    case notifications = "NOTIFICATIONS"
    case scaffold = "SCAFFOLD"
    case settings = "SETTINGS"
    case subscribe = "SUBSCRIBE"
    case vipGate = "VIPGATE"
}