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

// TODO: Content Wrapper of content or contentID
enum DeeplinkDestination {
    case profile(userID: Int)
    case closeUp(contentWrapper: CloseUpContentWrapper)
    case vipForum
    case trophyCase
    case externalURL
    
    init?(url: NSURL) {
        guard let host = url.host else {
            assertionFailure("We got a deep link URL but no host component, so we don't know where to navigate")
            return nil
        }
        
        switch host {
            case "content":
                guard let contentID = url.v_firstNonSlashPathComponent() else { return nil }
                self = .closeUp(contentWrapper: .contentID(id: contentID))
            case "profile":
                guard let userID = Int(url.v_firstNonSlashPathComponent()) else { return nil }
                self = .profile(userID: userID)
            case "vipForum":
                self = .vipForum
            case "profile/trophyCase":
                self = .trophyCase
            default:
                self = .externalURL
        }
    }
    
    init?(content: ContentModel) {
        switch content.type {
        case .image, .video, .gif:
            self = .closeUp(contentWrapper: .content(content: content))
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

/// A
enum CloseUpContentWrapper {
    case content(content: ContentModel)
    case contentID(id: Content.ID)
}
