//
//  Router.swift
//  victorious
//
//  Created by Tian Lan on 6/27/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

enum ViewTransition {
    case push
    case present
}

struct Router {
    private weak var originViewController: UIViewController!
    private let dependencyManager: VDependencyManager
    
    init(originViewController: UIViewController, dependencyManager: VDependencyManager) {
        self.originViewController = originViewController
        self.dependencyManager = dependencyManager
    }
    
    func navigate(to content: ContentModel, preferredTransition: ViewTransition = .push) {
        // TODO: actually support preferredTransition
        switch content.type {
            case .image, .video, .gif:
                showCloseUpView(for: content)
            case .link:
                guard
                    let linkedURL = content.linkedURL,
                    let destination = DeeplinkDestination(url: linkedURL) else {
                        return
                }
                switch destination {
                    case .profile: break
                    case .closeUp, .externalURL:
                        showCloseUpView(for: content)
                    case .vipForum:
                        ShowForumOperation(originViewController: originViewController, dependencyManager: dependencyManager, showVIP: true, animated: true).queue()
                }
            case .text:
                // We currently don't support tapping on text content
                break
        }
    }
    
    private func showCloseUpView(for content: ContentModel, preferredTransition: ViewTransition = .push) {
        let displayModifier = ShowCloseUpDisplayModifier(dependencyManager: dependencyManager, originViewController: originViewController)
        ShowCloseUpOperation.showOperation(forContent: content, displayModifier: displayModifier).queue()
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
