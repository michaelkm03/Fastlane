//
//  Router.swift
//  victorious
//
//  Created by Tian Lan on 6/27/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// A Router object that is able to navigate to a deeplink destination in the app
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
        guard let originViewController = self.originViewController else { return }
        ShowTrophyCaseOperation(originViewController: originViewController, dependencyManager: dependencyManager).queue()
    }
    
    private func showError() {
        let title = NSLocalizedString("Missing Content", comment: "The title of the alert saying we can't find a piece of content")
        let message = NSLocalizedString("Missing Content Message", comment: "A deep linked content has a wrong destination URL that we can't navigate to")
        originViewController?.v_showAlert(title: title, message: message)
    }
}
