//
//  Router.swift
//  victorious
//
//  Created by Tian Lan on 6/27/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// FUTURE:
/// - Queueing deep links (before scaffold is ready)
/// - Remove DeepLinkReceiver


struct Router {
    private weak var originViewController: UIViewController!
    private let dependencyManager: VDependencyManager
    
    init(originViewController: UIViewController, dependencyManager: VDependencyManager) {
        self.originViewController = originViewController
        self.dependencyManager = dependencyManager
    }
    
    func navigate(to content: ContentModel) {
        switch content.type {
            case .image, .video, .gif:
                showCloseUpView(for: content)
            case .link:
                guard let linkedURL = content.linkedURL else {
                    showError()
                    return
                }
                navigate(to: linkedURL)
            case .text:
                // FUTURE: We currently don't support tapping on text content
                break
        }
    }
    
    func navigate(to url: NSURL) {
        guard let destination = DeeplinkDestination(url: url) else {
            showError()
            return
        }
        
        switch destination {
            case .profile(let userID):
                showProfile(for: userID)
            case .closeUp(let contentID):
                showCloseUpView(for: contentID)
            case .vipForum:
                showVIPForum()
            case .externalURL:
                // FUTURE: Show Web Content
                break
        }
    }
    
    typealias ContentID = String
    private func showCloseUpView(for contentID: ContentID) {
        let displayModifier = ShowCloseUpDisplayModifier(dependencyManager: dependencyManager, originViewController: originViewController)
        ShowCloseUpOperation.showOperation(forContentID: contentID, displayModifier: displayModifier).queue()
    }
    
    private func showCloseUpView(for content: ContentModel) {
        let displayModifier = ShowCloseUpDisplayModifier(dependencyManager: dependencyManager, originViewController: originViewController)
        ShowCloseUpOperation.showOperation(forContent: content, displayModifier: displayModifier).queue()
    }
    
    private func showVIPForum() {
        ShowForumOperation(originViewController: originViewController, dependencyManager: dependencyManager, showVIP: true, animated: true).queue()
    }
    
    typealias UserID = Int
    private func showProfile(for userID: UserID) {
        ShowProfileOperation(originViewController: originViewController, dependencyManager: dependencyManager, userId: userID).queue()
    }
    
    private func showError() {
        let title = NSLocalizedString("Missing Content", comment: "The title of the alert saying we can't find a piece of content")
        let message = NSLocalizedString("Missing Content Message", comment: "A deep linked content has a wrong destination URL that we can't navigate to")
        originViewController.v_showAlert(title: title, message: message)
    }
}

private enum DeeplinkDestination {
    case profile(userID: Int)
    case closeUp(contentID: String)
    case vipForum
    case externalURL
    
    init?(url: NSURL) {
        switch url.scheme.lowercaseString {
            case "vthisapp":
                guard let host = url.host else {
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
                        self = .externalURL
                }
            default:
                self = .externalURL
        }
    }
}
