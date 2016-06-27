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
        switch content.type {
        case .image, .video, .gif:
            showCloseUpView(for: content)
        case .link:
            if let destination = DeeplinkDestination(url: content.linkedURL!) {
                navigate(to: destination)
            } else {
                showCloseUpView(for: content)
            }
        case .text:
            // We currently don't support tapping on text content
            break
        }
    }
    
    private func navigate(to destination: DeeplinkDestination, preferredTransition: ViewTransition = .push) {
        
    }
    
    private func showCloseUpView(for content: ContentModel, preferredTransition: ViewTransition = .push) {
        let displayModifier = ShowCloseUpDisplayModifier(dependencyManager: dependencyManager, originViewController: originViewController)
        ShowCloseUpOperation.showOperation(forContent: content, displayModifier: displayModifier).queue()
    }
}

private enum DeeplinkDestination {
    init?(url: NSURL) {
        switch url.host! {
            case "vthisapp": // deeplink cases
                break
            default: // externalURL case
                break
        }
        self = .profile // FIXME: take this out
    }
    
    case profile
    case closeUp
    case vipForum
    case externalURL
}
