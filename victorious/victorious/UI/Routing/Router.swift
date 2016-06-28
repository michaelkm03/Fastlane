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
/// - Unify navigating to `ContentModel` and `ContentID` by refactoring `ShowCloseUpOperation`
///

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
                guard
                    let linkedURL = content.linkedURL,
                    let destination = DeeplinkDestination(url: linkedURL)
                else {
                    showError()
                    return
                }
                switch destination {
                    case .profile: break
                    case .closeUp:
                        showCloseUpView(for: content)
                    case .vipForum:
                        showVIPForum()
                    case .externalURL:
                        // Show web content
                        break
                    
                }
            case .text:
                // We currently don't support tapping on text content
                break
        }
    }
    
    func navigate(to url: NSURL) {
        guard let destination = DeeplinkDestination(url: url) else {
            showError()
            return
        }
        
        switch destination {
            case .profile: break
            case .closeUp:
                guard let contentID = url.v_firstNonSlashPathComponent() else {
                    showError()
                    return
                }
                showCloseUpView(for: contentID)
            case .vipForum:
                showVIPForum()
            case .externalURL:
                // Show web content
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
    
    private func showError() {
        let title = NSLocalizedString("Missing Content", comment: "The title of the alert saying we can't find a piece of content")
        let message = NSLocalizedString("Missing Content Message", comment: "A deep linked content has a wrong destination URL that we can't navigate to")
        originViewController.v_showAlert(title: title, message: message)
    }
}

private struct DeeplinkMapper {
    private static var urlHostToDestinationMapping: [String: DeeplinkDestination] {
        return [
            "content": .closeUp,
            "profile": .profile,
            "vipForum": .vipForum,
        ]
    }
    
    typealias URLHostComponent = String
    
    static func deeplinkDestination(for host: URLHostComponent?) -> DeeplinkDestination? {
        guard let host = host else {
            return nil
        }
        return urlHostToDestinationMapping[host]
    }
}

private enum DeeplinkDestination {
    case profile
    case closeUp
    case vipForum
    case externalURL
    
    init?(url: NSURL) {
        switch url.scheme.lowercaseString {
        case "vthisapp":
            guard let destination = DeeplinkMapper.deeplinkDestination(for: url.host) else {
                return nil
            }
            self = destination
        default:
            self = .externalURL
        }
    }
}
