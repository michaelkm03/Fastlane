//
//  Router.swift
//  victorious
//
//  Created by Tian Lan on 6/27/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import SafariServices

// MARK: - Router

/// A Router object that is able to navigate to a deeplink destination in the app
struct Router {
    
    // MARK: - Initialization
    
    private weak var originViewController: UIViewController?
    private let dependencyManager: VDependencyManager

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
            case .closeUp(let contentWrapper): showCloseUpView(for: contentWrapper)
            case .vipForum: showVIPForum()
            case .externalURL(let url, let addressBarVisible): showWebView(for: url, addressBarVisible: addressBarVisible)
        }
    }
    
    // MARK: - Private Helper Functions
    
    private func showCloseUpView(for contentWrapper: CloseUpContentWrapper) {
        guard let originViewController = self.originViewController else { return }
        let displayModifier = ShowCloseUpDisplayModifier(dependencyManager: dependencyManager, originViewController: originViewController)

        switch contentWrapper {
            case .content(let content):
                guard content.type != .text, let contentID = content.id else {
                    return
                }
                ShowCloseUpOperation.showOperation(forContentID: contentID, displayModifier: displayModifier).queue()
            case .contentID(let id):
                ShowCloseUpOperation.showOperation(forContentID: id, displayModifier: displayModifier).queue()
        }
    }
    
    private func showVIPForum() {
        guard let originViewController = self.originViewController else { return }
        ShowForumOperation(originViewController: originViewController, dependencyManager: dependencyManager, showVIP: true, animated: true).queue()
    }
    
    private func showProfile(for userID: User.ID) {
        guard let originViewController = self.originViewController else { return }
        ShowProfileOperation(originViewController: originViewController, dependencyManager: dependencyManager, userId: userID).queue()
    }
    
    private func showWebView(for url: NSURL, addressBarVisible: Bool) {
        // Future: We currently have no way to hide address bar. This will be handled when we implement close up web view.
        let safariViewController = SFSafariViewController(URL: url)
        originViewController?.presentViewController(safariViewController, animated: true, completion: nil)
    }
    
    private func showError() {
        let title = NSLocalizedString("Missing Content", comment: "The title of the alert saying we can't find a piece of content")
        let message = NSLocalizedString("Missing Content Message", comment: "A deep linked content has a wrong destination URL that we can't navigate to")
        originViewController?.v_showAlert(title: title, message: message)
    }
}

// MARK: - Show Forum

private class ShowForumOperation: MainQueueOperation {
    private let dependencyManager: VDependencyManager
    private let animated: Bool
    private let showVIP: Bool
    private weak var originViewController: UIViewController?
    
    required init(originViewController: UIViewController, dependencyManager: VDependencyManager, showVIP: Bool = false, animated: Bool = true) {
        self.dependencyManager = dependencyManager
        self.showVIP = showVIP
        self.originViewController = originViewController
        self.animated = animated
    }
    
    override func start() {
        
        guard !self.cancelled else {
            finishedExecuting()
            return
        }
        
        beganExecuting()
        
        let templateKey = showVIP ? "vipForum" : "forum"
        let templateValue = dependencyManager.templateValueOfType(ForumViewController.self, forKey: templateKey)
        guard let viewController = templateValue as? ForumViewController else {
            finishedExecuting()
            return
        }
        
        let navigationController = UINavigationController(rootViewController: viewController)
        originViewController?.presentViewController(navigationController, animated: animated) {
            self.finishedExecuting()
        }
    }
}

// MARK: - Show Profile

private class ShowProfileOperation: MainQueueOperation {
    private let dependencyManager: VDependencyManager
    private weak var originViewController: UIViewController?
    private let userId: Int
    
    init( originViewController: UIViewController,
          dependencyManager: VDependencyManager,
          userId: Int) {
        self.originViewController = originViewController
        self.dependencyManager = dependencyManager
        self.userId = userId
    }
    
    override func start() {
        super.start()
        defer {
            finishedExecuting()
        }
        
        // Check if already showing the a user's profile
        if let originViewControllerProfile = originViewController as? VNewProfileViewController
            where originViewControllerProfile.user?.id == userId {
            return
        }
        
        guard let profileViewController = dependencyManager.userProfileViewController(withRemoteID: userId),
            let originViewController = originViewController else {
                return
        }
        
        if let originViewController = originViewController as? UINavigationController {
            originViewController.pushViewController(profileViewController, animated: true)
        } else {
            originViewController.navigationController?.pushViewController(profileViewController, animated: true)
        }
    }
}

// MARK: - Show Close Up View

/// Encapsulates values used when displaying the close up view
/// and other view controllers associated with these operations
private struct ShowCloseUpDisplayModifier {
    let dependencyManager: VDependencyManager
    let animated: Bool
    weak var originViewController: UIViewController?
    
    init(dependencyManager: VDependencyManager, originViewController: UIViewController, animated: Bool = true) {
        self.dependencyManager = dependencyManager
        self.originViewController = originViewController
        self.animated = animated
    }
}

/// Shows a close up view displaying the provided content.
private class ShowCloseUpOperation: MainQueueOperation {
    private let displayModifier: ShowCloseUpDisplayModifier
    private var content: ContentModel?
    private var contentID: String?
    private(set) var displayedCloseUpView: CloseUpContainerViewController?
    
    static func showOperation(forContent content: ContentModel, displayModifier: ShowCloseUpDisplayModifier) -> MainQueueOperation {
        return ShowPermissionedCloseUpOperation(content: content, displayModifier: displayModifier)
    }
    
    static func showOperation(forContentID contentID: String, displayModifier: ShowCloseUpDisplayModifier) -> MainQueueOperation {
        return ShowFetchedCloseUpOperation(contentID: contentID, displayModifier: displayModifier)
    }
    
    init(content: ContentModel, displayModifier: ShowCloseUpDisplayModifier) {
        self.displayModifier = displayModifier
        self.content = content
        super.init()
    }
    
    init(contentID: String, displayModifier: ShowCloseUpDisplayModifier) {
        self.displayModifier = displayModifier
        self.contentID = contentID
        super.init()
    }
    
    override func start() {
        defer {
            finishedExecuting()
        }
        
        guard
            !cancelled,
            let childDependencyManager = displayModifier.dependencyManager.childDependencyForKey("closeUpView"),
            let originViewController = displayModifier.originViewController,
            let contentID = contentID ?? content?.id
            else {
                return
        }
        
        let apiPath = APIPath(templatePath: childDependencyManager.relatedContentURL, macroReplacements: [
            "%%CONTENT_ID%%": contentID,
            "%%CONTEXT%%" : childDependencyManager.context
            ])
        
        let closeUpViewController = CloseUpContainerViewController(
            dependencyManager: childDependencyManager,
            contentID: contentID,
            content: content,
            streamAPIPath: apiPath
        )
        displayedCloseUpView = closeUpViewController
        
        let animated = displayModifier.animated
        if let originViewController = originViewController as? UINavigationController {
            originViewController.pushViewController(closeUpViewController, animated: animated)
        } else {
            originViewController.navigationController?.pushViewController(closeUpViewController, animated: animated)
        }
    }
}

/// Shows a close up view for a given piece of content after checking
/// permissions and displaying a vip gate as appropriate.
private class ShowPermissionedCloseUpOperation: MainQueueOperation {
    private let displayModifier: ShowCloseUpDisplayModifier
    private var content: ContentModel
    
    init(content: ContentModel, displayModifier: ShowCloseUpDisplayModifier) {
        self.displayModifier = displayModifier
        self.content = content
        super.init()
    }
    
    override func start() {
        defer {
            finishedExecuting()
        }
        
        guard !cancelled else {
            return
        }
        
        let displayModifier = self.displayModifier
        let dependencyManager = displayModifier.dependencyManager
        let content = self.content
        
        if content.isVIPOnly {
            let scaffold = dependencyManager.scaffoldViewController()
            let showVIPFlowOperation = ShowVIPFlowOperation(originViewController: scaffold, dependencyManager: dependencyManager) { success in
                if success {
                    ShowCloseUpOperation(content: content, displayModifier: displayModifier).queue()
                }
            }
            
            let completionBlock = self.completionBlock
            showVIPFlowOperation.rechainAfter(self).queue() { _ in
                completionBlock?()
            }
        } else {
            ShowCloseUpOperation(content: content, displayModifier: displayModifier).rechainAfter(self).queue()
        }
    }
}

/// Fetches a piece of content and shows a close up view containing it.
private class ShowFetchedCloseUpOperation: MainQueueOperation {
    private let displayModifier: ShowCloseUpDisplayModifier
    private var contentID: String
    
    init(contentID: String, displayModifier: ShowCloseUpDisplayModifier, checkPermissions: Bool = true) {
        self.displayModifier = displayModifier
        self.contentID = contentID
        super.init()
    }
    
    override func main() {
        defer {
            finishedExecuting()
        }
        
        let displayModifier = self.displayModifier
        guard
            !cancelled,
            let userID = VCurrentUser.user()?.remoteId.integerValue,
            let contentFetchURL = displayModifier.dependencyManager.contentFetchURL
            else {
                return
        }
        
        let showCloseUpOperation = ShowCloseUpOperation(contentID: contentID, displayModifier: displayModifier)
        showCloseUpOperation.rechainAfter(self).queue()
        
        let contentFetchOperation = ContentFetchOperation(
            macroURLString: contentFetchURL,
            currentUserID: String(userID),
            contentID: contentID
        )
        
        let completionBlock = showCloseUpOperation.completionBlock
        contentFetchOperation.rechainAfter(showCloseUpOperation).queue() { [weak self] results, _, _ in
            guard
                let strongSelf = self,
                let shownCloseUpView = showCloseUpOperation.displayedCloseUpView
            else {
                completionBlock?()
                return
            }
            
            guard let content = results?.first as? ContentModel else {
                // Display error message.
                shownCloseUpView.updateError()
                completionBlock?()
                return
            }
            
            if content.isVIPOnly {
                let dependencyManager = displayModifier.dependencyManager
                let showVIPFlowOperation = ShowVIPFlowOperation(originViewController: shownCloseUpView, dependencyManager: dependencyManager) { success in
                    if success {
                        shownCloseUpView.updateContent(content)
                    }
                    else {
                        shownCloseUpView.navigationController?.popViewControllerAnimated(true)
                    }
                }
                
                showVIPFlowOperation.rechainAfter(strongSelf).queue() { _ in
                    completionBlock?()
                }
            }
            else {
                shownCloseUpView.updateContent(content)
                completionBlock?()
            }
        }
    }
}

private extension VDependencyManager {
    var relatedContentURL: String {
        return stringForKey("streamURL") ?? ""
    }
    
    var context: String {
        return stringForKey("related.content.context") ?? ""
    }
    
    var contentFetchURL: String? {
        return networkResources?.stringForKey("contentFetchURL")
    }
}
