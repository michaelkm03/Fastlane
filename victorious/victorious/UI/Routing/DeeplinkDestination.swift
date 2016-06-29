//
//  DeeplinkDestination.swift
//  victorious
//
//  Created by Tian Lan on 6/29/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// A deeplink destination that we can naviagte to within the app, or an external URL
/// e.g. A piece of content, a user, or a specific screen that is deep linked to.
enum DeeplinkDestination {
    case profile(userID: Int)
    case closeUp(contentID: String)
    case vipForum
    case trophyCase
    case externalURL
    
    init?(url: NSURL) {
        let scheme = url.scheme.lowercaseString
        
        // First check if we have a deep link URL or an external URL
        guard scheme == "vthisapp" else {
            self = .externalURL
            return
        }
        
        // Then find out where we would like to deep link to
        guard let host = url.host else {
            assertionFailure("We got a deep link URL but no host component, so we don't know where to navigate")
            return nil
        }
        
        switch host {
        case "content":
            guard let contentID = url.v_firstNonSlashPathComponent() else { return nil }
            self = .closeUp(contentID: contentID)
        case "profile":
            guard let userID = Int(url.v_firstNonSlashPathComponent()) else { return nil }
            self = .profile(userID: userID)
        case "vipForum":
            self = .vipForum
        case "profile/trophyCase":
            self = .trophyCase
        default:
            assertionFailure("Unrecgonized host for the deep link URL")
            return nil
        }
    }
    
    init?(content: ContentModel) {
        switch content.type {
        case .image, .video, .gif:
            guard let contentID = content.id else { return nil }
            self = .closeUp(contentID: contentID)
        case .link:
            guard
                let url = content.linkedURL,
                let validDestination = DeeplinkDestination(url: url)
                else {
                    return nil
            }
            self = validDestination
        case .text:
            return nil
        }
    }
    
    init(userID: User.ID) {
        self = .profile(userID: userID)
    }
}
