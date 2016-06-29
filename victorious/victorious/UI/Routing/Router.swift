//
//  Router.swift
//  victorious
//
//  Created by Tian Lan on 6/27/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// A Router object that is able to navigate to a destination in the app,
/// e.g. A piece of content, a user, or a specific screen that is deep linked to.
/// Use one of the `navigate(to:) APIs to perform the navigation.
struct Router {
    
    // MARK: - Initialization
    
    private weak var originViewController: UIViewController?
    private let dependencyManager: VDependencyManager
    typealias ContentID = String
    typealias UserID = Int

    init(originViewController: UIViewController, dependencyManager: VDependencyManager) {
        self.originViewController = originViewController
        self.dependencyManager = dependencyManager
    }
    
    // MARK: - API
    
    func navigate(to destination: DeeplinkDestination?) {
        guard let destination = destination else {
            showError()
            return
        }
        
        switch destination {
            case .profile(let userID): showProfile(for: userID)
            case .closeUp(let contentID): showCloseUpView(for: contentID)
            case .vipForum: showVIPForum()
            case .trophyCase: showTrophyCase()
            case .externalURL: break // FUTURE: Show Web Content
        }
    }
    
    // MARK: - Private Helper Functions

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
    
    private func showProfile(for userID: UserID) {
        guard let originViewController = self.originViewController else { return }
        ShowProfileOperation(originViewController: originViewController, dependencyManager: dependencyManager, userId: userID).queue()
    }
    
    private func showTrophyCase() {
        
    }
    
    private func showError() {
        let title = NSLocalizedString("Missing Content", comment: "The title of the alert saying we can't find a piece of content")
        let message = NSLocalizedString("Missing Content Message", comment: "A deep linked content has a wrong destination URL that we can't navigate to")
        originViewController?.v_showAlert(title: title, message: message)
    }
}

enum DeeplinkDestination {
    case profile(userID: Int)
    case closeUp(contentID: String)
    case vipForum
    case trophyCase
    case externalURL
    
    typealias ContentID = String
    typealias UserID = Int
    
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
            case "trophyCase":
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
    
    init(userID: UserID) {
        self = .profile(userID: userID)
    }
}
