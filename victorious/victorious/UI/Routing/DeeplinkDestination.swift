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
enum DeeplinkDestination: Equatable {
    case profile(userID: Int)
    case closeUp(contentID: Content.ID)
    case vipForum
    case externalURL(url: NSURL, addressBarVisible: Bool)
    
    init?(url: NSURL) {
        guard url.scheme == "vthisapp" else {
            v_log("Received links in wrong format. All links should be in deep link format according to https://wiki.victorious.com/display/ENG/Deep+Linking+Specification")
            return nil
        }
        
        guard let host = url.host else {
            v_log("We got a deep link URL but no host component, so we don't know where to navigate")
            return nil
        }
        
        switch host {
            case "content":
                guard let contentID = url.pathWithoutLeadingSlash else { return nil }
                self = .closeUp(contentID: contentID)
            case "profile":
                guard
                    let path = url.pathWithoutLeadingSlash,
                    let userID = Int(path)
                else {
                    return nil
                }
                self = .profile(userID: userID)
            case "vipForum":
                self = .vipForum
            case "webURL":
                guard
                    let path = url.pathWithoutLeadingSlash,
                    let externalURL = NSURL(string: path)
                else {
                    return nil
                }
                self = .externalURL(url: externalURL, addressBarVisible: true)
            case "hiddenWebURL":
                guard
                    let path = url.pathWithoutLeadingSlash,
                    let externalURL = NSURL(string: path)
                else {
                    return nil
                }
                self = .externalURL(url: externalURL, addressBarVisible: false)
            default:
                return nil
        }
    }
    
    init?(content: ContentModel) {
        switch content.type {
        case .image, .video, .gif, .text:
            guard let id = content.id else {
                return nil
            }
            self = .closeUp(contentID: id)
        case .link:
            guard
                let url = content.linkedURL,
                let validDestination = DeeplinkDestination(url: url)
            else {
                return nil
            }
            self = validDestination
        }
    }
    
    init(userID: User.ID) {
        self = .profile(userID: userID)
    }
}

func ==(lhs: DeeplinkDestination, rhs: DeeplinkDestination) -> Bool {
    switch (lhs, rhs) {
        case (let .profile(id1), let .profile(id2)): return id1 == id2
        case (let .closeUp(contentWrapper1), let .closeUp(contentWrapper2)): return contentWrapper1 == contentWrapper2
        case (.vipForum, .vipForum): return true
        case (let .externalURL(url1, visible1), let .externalURL(url2, visible2)): return url1 == url2 && visible1 == visible2
        default: return false
    }
}
