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
    case vipSubscription
    case externalURL(url: NSURL, configuration: ExternalLinkDisplayConfiguration)
    
    init?(url: NSURL, isVIPOnly: Bool = false, title: String? = nil, forceModal: Bool = true) {
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
                let configuration = ExternalLinkDisplayConfiguration(addressBarVisible: true, forceModal: false, isVIPOnly: isVIPOnly, title: "")
                self = .externalURL(url: externalURL, configuration: configuration)
            case "hiddenWebURL":
                guard
                    let path = url.pathWithoutLeadingSlash,
                    let externalURL = NSURL(string: path)
                else {
                    return nil
                }
                let configuration = ExternalLinkDisplayConfiguration(addressBarVisible: false, forceModal: forceModal, isVIPOnly: isVIPOnly, title: title)
                self = .externalURL(url: externalURL, configuration: configuration)
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
                    let validDestination = DeeplinkDestination(url: url, isVIPOnly: content.isVIPOnly, forceModal: false)
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
        case (.vipSubscription, .vipSubscription): return true
        // Don't need to check titles since they could differ based on the presenting view controller
        case (let .externalURL(url1, _), let .externalURL(url2, _)): return url1 == url2
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

// Lets the presenting viewcontroller control how the webcontent will be displayed
struct ExternalLinkDisplayConfiguration {
    let addressBarVisible: Bool
    let forceModal: Bool
    let isVIPOnly: Bool
    let title: String?
    let transitionAnimated = true
}
