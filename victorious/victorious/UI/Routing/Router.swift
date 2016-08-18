//
//  Router.swift
//  victorious
//
//  Created by Tian Lan on 6/27/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import SafariServices

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
            case .vipSubscription: showVIPSubscription()
            case .externalURL(let url, let configuration): showWebView(for: url, configuration: configuration)
        }
    }
    
    // MARK: - Private Helper Functions
    
    private func showCloseUpView(for contentWrapper: CloseUpContentWrapper) {
        guard let originViewController = self.originViewController else { return }
        let displayModifier = ShowCloseUpDisplayModifier(dependencyManager: dependencyManager, originViewController: originViewController)

        switch contentWrapper {
            case .content(let content, let forceFetch):
                guard content.type != .text else {
                    return
                }
                
                checkForPermissionBeforeRouting(contentIsForVIPOnly: content.isVIPOnly) { success in
                    if success {
                        if !forceFetch {
                            ShowCloseUpOperation(content: content, displayModifier: displayModifier).queue()
                        }
                        else {
                            guard let contentID = content.id else {
                                assertionFailure("We are routing to a content with no ID")
                                return
                            }
                            ShowFetchedCloseUpOperation(contentID: contentID, displayModifier: displayModifier).queue()
                        }
                    }
                }
            case .contentID(let contentID):
                ShowFetchedCloseUpOperation(contentID: contentID, displayModifier: displayModifier).queue()
        }
    }
    
    private func showVIPForum() {
        guard let originViewController = self.originViewController else {
            return
        }
        
        checkForPermissionBeforeRouting(contentIsForVIPOnly: true) { success in
            if success {
                ShowForumOperation(originViewController: originViewController, dependencyManager: self.dependencyManager, showVIP: true, animated: true).queue()
            }
        }
    }
    
    private func showVIPSubscription(completion completion: ((success: Bool) -> Void)? = nil) {
        guard let originViewController = self.originViewController else {
            return
        }
        
        ShowVIPSubscriptionOperation(originViewController: originViewController, dependencyManager: dependencyManager, completion: completion).queue()
    }
    
    private func showProfile(for userID: User.ID) {
        guard let originViewController = self.originViewController else {
            return
        }
        ShowProfileOperation(originViewController: originViewController, dependencyManager: dependencyManager, userId: userID).queue()
    }
    
    private func showWebView(for url: NSURL, configuration: ExternalLinkDisplayConfiguration) {
        checkForPermissionBeforeRouting(contentIsForVIPOnly: configuration.isVIPOnly) { success in
            if success {
                
                if configuration.addressBarVisible {
                    let safariViewController = SFSafariViewController(URL: url)
                    self.originViewController?.presentViewController(safariViewController, animated: true, completion: nil)
                }
                
                else if let originVC = self.originViewController {
                    ShowWebContentOperation(originViewController: originVC, url: url.absoluteString, dependencyManager: self.dependencyManager, configuration: configuration).queue()
                }
            }
        }
    }
    
    private func showError() {
        let title = NSLocalizedString("Missing Content", comment: "The title of the alert saying we can't find a piece of content")
        let message = NSLocalizedString("Missing Content Message", comment: "A deep linked content has a wrong destination URL that we can't navigate to")
        originViewController?.v_showAlert(title: title, message: message)
    }
    
    func checkForPermissionBeforeRouting(contentIsForVIPOnly isVIPOnly: Bool = false, completion: ((success: Bool) -> Void)? = nil) {
        guard let currentUser = VCurrentUser.user() else {
            return
        }
        
        if isVIPOnly && !currentUser.hasValidVIPSubscription {
            showVIPSubscription(completion: completion)
        }
        else {
            completion?(success: true)
        }
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
        super.start()
        beganExecuting()
        
        guard !self.cancelled else {
            finishedExecuting()
            return
        }
        
        let templateKey = showVIP ? "vipForum" : "forum"
        let templateValue = dependencyManager.templateValueOfType(ForumViewController.self, forKey: templateKey)
        guard let viewController = templateValue as? ForumViewController else {
            finishedExecuting()
            return
        }
        
        let navigationController = UINavigationController(rootViewController: viewController)
        originViewController?.presentViewController(navigationController, animated: animated) {
            ///
            /// FUTURE:
            /// This HACK is added in order to avoid the other HACK related to the main feed going blank. 
            /// The VIP forum had no way of initializing it's network source since this was done only once
            /// per app launch for both of the Forums. More info in this ticket: https://jira.victorious.com/browse/IOS-5560
            ///
            if self.showVIP {
                viewController.forumNetworkSource?.setUpIfNeeded()
            }

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
        beganExecuting()
        
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
    
    init(contentID: String, displayModifier: ShowCloseUpDisplayModifier) {
        self.displayModifier = displayModifier
        self.contentID = contentID
        super.init()
    }
    
    init(content: ContentModel, displayModifier: ShowCloseUpDisplayModifier) {
        self.displayModifier = displayModifier
        self.content = content
        super.init()
    }
    
    override func start() {
        super.start()
        beganExecuting()
        
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

/// Fetches a piece of content and shows a close up view containing it.
private class ShowFetchedCloseUpOperation: MainQueueOperation {
    private let displayModifier: ShowCloseUpDisplayModifier
    private var contentID: String
    
    init(contentID: String, displayModifier: ShowCloseUpDisplayModifier) {
        self.displayModifier = displayModifier
        self.contentID = contentID
        super.init()
    }
    
    override func start() {
        super.start()
        beganExecuting()
        
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
        
        // Set up ShowCloseUpOperation and chain it
        let showCloseUpOperation = ShowCloseUpOperation(contentID: contentID, displayModifier: displayModifier)
        showCloseUpOperation.rechainAfter(self)
        
        // Set up ContentFetchOperation and chain it
        let contentFetchOperation = ContentFetchOperation(
            macroURLString: contentFetchURL,
            currentUserID: String(userID),
            contentID: contentID
        )
        contentFetchOperation.rechainAfter(showCloseUpOperation)
        
        // Queue operations. We queue the operations after setting up dependency graph for NSOperationQueue performance reasons.
        showCloseUpOperation.queue()
        contentFetchOperation.queue() { results, _, _ in
            guard let shownCloseUpView = showCloseUpOperation.displayedCloseUpView else {
                return
            }
            
            guard let content = results?.first as? ContentModel else {
                // Display error message.
                shownCloseUpView.updateError()
                return
            }
            
            // Check for permissions before we continue to show the content
            let router = Router(originViewController: shownCloseUpView, dependencyManager: displayModifier.dependencyManager)
            router.checkForPermissionBeforeRouting(contentIsForVIPOnly: content.isVIPOnly) { success in
                if success {
                    shownCloseUpView.updateContent(content)
                }
                else {
                    shownCloseUpView.navigationController?.popViewControllerAnimated(true)
                }
            }
        }
    }
}

// MARK: - Show Web Content

private class ShowWebContentOperation: MainQueueOperation {
    private let originViewController: UIViewController
    private let createFetchOperation: () -> FetchWebContentOperation
    private let dependencyManager: VDependencyManager
    private let configuration: ExternalLinkDisplayConfiguration
    
    init (originViewController: UIViewController, url: String, dependencyManager: VDependencyManager, configuration: ExternalLinkDisplayConfiguration) {
        self.originViewController = originViewController
        self.dependencyManager = dependencyManager
        self.configuration = configuration
        self.createFetchOperation = {
            return WebViewHTMLFetchOperation(urlPath: url)
        }
    }
    
    override func start() {
        super.start()
        beganExecuting()
        
        guard !cancelled else {
            finishedExecuting()
            return
        }
        
        //We show the navigation and dismiss button if the view controller is presented modally, 
        // since there would be no way to dimiss the view controller otherwise
        let viewController = WebContentViewController(shouldShowNavigationButtons: configuration.forceModal)
        
        let fetchOperation = createFetchOperation()
        
        fetchOperation.after(self).queue { [weak fetchOperation] results, error, cancelled in
            guard let fetchOperation = fetchOperation else {
                return
            }
            
            guard let htmlString = fetchOperation.resultHTMLString where error == nil else {
                viewController.setFailure(with: error)
                return
            }
            
            viewController.load(htmlString, baseURL: fetchOperation.publicBaseURL)
        }
        
        viewController.automaticallyAdjustsScrollViewInsets = false
        viewController.edgesForExtendedLayout = .All
        viewController.extendedLayoutIncludesOpaqueBars = true
        viewController.title = configuration.title
        
        if let navigationController = (originViewController as? UINavigationController) ?? originViewController.navigationController where !configuration.forceModal {
            navigationController.pushViewController(viewController, animated: configuration.transitionAnimated)
            finishedExecuting()
        }
        else {
            let navigationController = UINavigationController(rootViewController: viewController)
            
            dependencyManager.applyStyleToNavigationBar(navigationController.navigationBar)
        
            originViewController.presentViewController(navigationController, animated: configuration.transitionAnimated) {
                self.finishedExecuting()
            }
        }
    }
}

// MARK: - Show VIP Flow Operation

private class ShowVIPSubscriptionOperation: MainQueueOperation {
    private let dependencyManager: VDependencyManager
    private let animated: Bool
    private let completion: VIPFlowCompletion?
    private weak var originViewController: UIViewController?
    private(set) var showedGate = false
    
    required init(originViewController: UIViewController, dependencyManager: VDependencyManager, animated: Bool = true, completion: VIPFlowCompletion? = nil) {
        self.dependencyManager = dependencyManager
        self.originViewController = originViewController
        self.animated = animated
        self.completion = completion
    }
    
    override func start() {
        super.start()
        beganExecuting()
        
        defer {
            finishedExecuting()
        }
        
        guard
            !cancelled,
            let originViewController = originViewController,
            let vipFlow = dependencyManager.templateValueOfType(VIPFlowNavigationController.self, forKey: "vipPaygateScreen") as? VIPFlowNavigationController
            else {
                return
        }
        
        guard VCurrentUser.user()?.hasValidVIPSubscription != true else {
            completion?(true)
            return
        }
        
        vipFlow.completionBlock = completion
        showedGate = true
        originViewController.presentViewController(vipFlow, animated: animated, completion: nil)
    }
}

// MARK: - Dependency Manager Extensions 

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
