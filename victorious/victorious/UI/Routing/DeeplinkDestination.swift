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
    case closeUp(contentWrapper: CloseUpContentWrapper)
    case vipForum
    case externalURL(url: NSURL, addressBarVisible: Bool, isVIPOnly: Bool)
    case fixedWebContent(type: FixedWebContentType, forceModal: Bool)
    
    init?(url: NSURL, isVIPOnly: Bool = false) {
        guard url.scheme == "vthisapp" else {
            logger.info("Received link (\(url.absoluteString)) in wrong format. All links should be in deep link format according to https://wiki.victorious.com/display/ENG/Deep+Linking+Specification")
            return nil
        }
        
        guard let host = url.host else {
            logger.info("Received link (\(url.absoluteString)) with no host component, so we don't know where to navigate.")
            return nil
        }
        
        switch host {
            case "content":
                guard let contentID = url.pathWithoutLeadingSlash else { return nil }
                self = .closeUp(contentWrapper: .contentID(id: contentID))
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
                self = .externalURL(url: externalURL, addressBarVisible: true, isVIPOnly: isVIPOnly)
            case "hiddenWebURL":
                guard
                    let path = url.pathWithoutLeadingSlash,
                    let externalURL = NSURL(string: path)
                else {
                    return nil
                }
                self = .externalURL(url: externalURL, addressBarVisible: false, isVIPOnly: isVIPOnly)
            default:
                return nil
        }
    }
    
    init?(content: ContentModel) {
        switch content.type {
        case .image, .video, .gif, .text:
            self = .closeUp(contentWrapper: .content(content: content))
        case .link:
            guard
                let url = content.linkedURL,
                let validDestination = DeeplinkDestination(url: url, isVIPOnly: content.isVIPOnly)
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
        case (let .externalURL(url1, visible1, isVIPOnly1), let .externalURL(url2, visible2, isVIPOnly2)): return url1 == url2 && visible1 == visible2 && isVIPOnly1 == isVIPOnly2
        default: return false
    }
}

/// A wrapper around content to be shown in close up view.
/// This is needed because we could either pass a content object or content ID to close up view.
/// If we pass a content object, it will be shown directly. While if we pass a content ID, it'll fetch the content from network.
enum CloseUpContentWrapper: Equatable {
    case content(content: ContentModel)
    case contentID(id: Content.ID)
}

func ==(lhs: CloseUpContentWrapper, rhs: CloseUpContentWrapper) -> Bool {
    switch (lhs, rhs) {
        case (let .content(content1), let .content(content2)): return content1 == content2
        case (let .contentID(id1), let.contentID(id2)): return id1 == id2
        default: return false
    }
}
