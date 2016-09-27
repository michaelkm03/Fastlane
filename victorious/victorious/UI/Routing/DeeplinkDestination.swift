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
    case externalURL(url: URL, configuration: ExternalLinkDisplayConfiguration)
    
    init?(url: URL, isVIPOnly: Bool = false, title: String? = nil, forceModal: Bool = true) {
        guard url.scheme == "vthisapp" else {
            Log.info("Received link (\(url.absoluteString)) in wrong format. All links should be in deep link format according to https://wiki.victorious.com/display/ENG/Deep+Linking+Specification")
            return nil
        }
        
        guard let host = url.host else {
            Log.info("Received link (\(url.absoluteString)) with no host component, so we don't know where to navigate.")
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
                    let externalURL = URL(string: path)
                else {
                    return nil
                }
                let configuration = ExternalLinkDisplayConfiguration(addressBarVisible: true, forceModal: forceModal, isVIPOnly: isVIPOnly, title: "")
                self = .externalURL(url: externalURL, configuration: configuration)
            case "hiddenWebURL":
                guard
                    let path = url.pathWithoutLeadingSlash,
                    let externalURL = URL(string: path)
                else {
                    return nil
                }
                let configuration = ExternalLinkDisplayConfiguration(addressBarVisible: false, forceModal: forceModal, isVIPOnly: isVIPOnly, title: title)
                self = .externalURL(url: externalURL, configuration: configuration)
            default:
                return nil
        }
    }
    
    /// Specifies a content destination to route to.
    /// - parameters:
    ///     - content: The content we are routing to.
    ///     - forceFetch: Should we perform a content fetch when we reach the destination.
    /// - note:
    /// In mose cases, we want to fetch the content after routing because backend may send us lightweight content in many contexts, e.g. in grid stream or chat feed.
    /// However, when transitioning from a stage content, we don't want to fetch again because we want to keep the video playback in sync.
    init?(content: Content, forceFetch: Bool = true) {
        switch content.type {
            case .image, .video, .gif, .text:
                self = .closeUp(contentWrapper: .content(content: content, forceFetch: forceFetch))
            case .link:
                guard
                    let url = content.linkedURL,
                    let validDestination = DeeplinkDestination(url: url, isVIPOnly: content.isVIPOnly, forceModal: true)
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
    case content(content: Content, forceFetch: Bool)
    case contentID(id: Content.ID)
}

func ==(lhs: CloseUpContentWrapper, rhs: CloseUpContentWrapper) -> Bool {
    switch (lhs, rhs) {
        case (let .content(content1, _), let .content(content2, _)): return content1 == content2
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
