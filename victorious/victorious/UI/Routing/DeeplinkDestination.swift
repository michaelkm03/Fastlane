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
    case closeUp(contentWrapper: CloseUpContentWrapper)
    case vipForum
    case externalURL(url: NSURL, addressBarVisible: Bool)
    
    init?(url: NSURL) {
        guard url.scheme == "vthisapp" else {
            assertionFailure("Received links in wrong format. All links should be in deep link format according to https://wiki.victorious.com/display/ENG/Deep+Linking+Specification")
            return nil
        }
        
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
            case "webURL":
                guard let externalURL = NSURL(string: url.v_firstNonSlashPathComponent()) else { return nil }
                self = .externalURL(url: externalURL, addressBarVisible: true)
            case "hiddenWebURL":
                guard let externalURL = NSURL(string: url.v_firstNonSlashPathComponent()) else { return nil }
                self = .externalURL(url: externalURL, addressBarVisible: false)
            default:
                return nil
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

/// A wrapper around content to be shown in close up view.
/// This is needed because we could either pass a content object or content ID to close up view.
/// If we pass a content object, it will be shown directly. While if we pass a content ID, it'll fetch the content from network.
enum CloseUpContentWrapper {
    case content(content: ContentModel)
    case contentID(id: Content.ID)
}
