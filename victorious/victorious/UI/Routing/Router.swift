//
//  Router.swift
//  victorious
//
//  Created by Tian Lan on 6/27/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// FUTURE: Will do these in the following PR
/// - Queueing deep links (before scaffold is ready)
/// - Remove DeepLinkReceiver

/// A Router object that is able to navigate to a destination in the app,
/// e.g. A piece of content, a user, or a specific screen that is deep linked to.
/// Use one of the `navigate(to:) APIs to perform the navigation.
struct Router {
    
    // MARK: - Initialization
    
    private weak var originViewController: UIViewController?
    private let dependencyManager: VDependencyManager
    
    init(originViewController: UIViewController, dependencyManager: VDependencyManager) {
        self.originViewController = originViewController
        self.dependencyManager = dependencyManager
    }
    
    // MARK: - API
    
    /// Performs navigation to a piece of content
    func navigate(to content: ContentModel) {
        switch content.type {
            case .image, .video, .gif: showCloseUpView(for: content)
            case .link: navigate(to: content.linkedURL)
            case .text: break // FUTURE: We currently don't support tapping on text content
        }
    }
    
    /// Performs navigation to a deep link URL
    func navigate(to deeplinkURL: NSURL?) {
        guard
            let url = deeplinkURL,
            let destination = DeeplinkDestination(url: url)
        else {
            showError()
            return
        }
        
        switch destination {
            case .profile(let userID): showProfile(for: userID)
            case .closeUp(let contentID): showCloseUpView(for: contentID)
            case .vipForum: showVIPForum()
            case .externalURL: break // FUTURE: Show Web Content
        }
    }
    
    // MARK: - Private Helper Functions

    typealias ContentID = String
    private func showCloseUpView(for contentID: ContentID) {
        guard let originViewController = self.originViewController else { return }
        let displayModifier = ShowCloseUpDisplayModifier(dependencyManager: dependencyManager, originViewController: originViewController)
        ShowCloseUpOperation.showOperation(forContentID: contentID, displayModifier: displayModifier).queue()
    }
    
    private func showCloseUpView(for content: ContentModel) {
        guard let originViewController = self.originViewController else { return }
        let displayModifier = ShowCloseUpDisplayModifier(dependencyManager: dependencyManager, originViewController: originViewController)
        ShowCloseUpOperation.showOperation(forContent: content, displayModifier: displayModifier).queue()
    }
    
    private func showVIPForum() {
        guard let originViewController = self.originViewController else { return }
        ShowForumOperation(originViewController: originViewController, dependencyManager: dependencyManager, showVIP: true, animated: true).queue()
    }
    
    typealias UserID = Int
    private func showProfile(for userID: UserID) {
        guard let originViewController = self.originViewController else { return }
        ShowProfileOperation(originViewController: originViewController, dependencyManager: dependencyManager, userId: userID).queue()
    }
    
    private func showError() {
        let title = NSLocalizedString("Missing Content", comment: "The title of the alert saying we can't find a piece of content")
        let message = NSLocalizedString("Missing Content Message", comment: "A deep linked content has a wrong destination URL that we can't navigate to")
        originViewController?.v_showAlert(title: title, message: message)
    }
}

private enum DeeplinkDestination {
    case profile(userID: Int)
    case closeUp(contentID: String)
    case vipForum
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
                guard let contentID = url.v_firstNonSlashPathComponent() else {
                    return nil
                }
                self = .closeUp(contentID: contentID)
            case "profile":
                guard let userID = Int(url.v_firstNonSlashPathComponent()) else {
                    return nil
                }
                self = .profile(userID: userID)
            case "vipForum":
                self = .vipForum
            default:
                assertionFailure("Unrecgonized host for the deep link URL")
                return nil
        }
    }
}
