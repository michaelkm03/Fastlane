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
                guard url.isHTTPScheme else {
                    self.showError()
                    return
                }
                    
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
        guard let currentUser = VCurrentUser.user else {
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

private final class ShowForumOperation: AsyncOperation<Void> {
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
    
    override var executionQueue: Queue {
        return .main
    }
    
    override func execute(finish: (result: OperationResult<Void>) -> Void) {

        let templateKey = showVIP ? "vipForum" : "forum"
        let templateValue = dependencyManager.templateValueOfType(ForumViewController.self, forKey: templateKey)
        guard let viewController = templateValue as? ForumViewController else {
            let error = NSError(domain: "ShowForumOperation", code: -1, userInfo: nil)
            finish(result: .failure(error))
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
            finish(result: .success())
        }
    }
}

// MARK: - Show Profile

private final class ShowProfileOperation: AsyncOperation<Void> {
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
    
    override var executionQueue: Queue {
        return .main
    }
    
    override func execute(finish: (result: OperationResult<Void>) -> Void) {
        
        // Check if already showing the a user's profile
        guard (originViewController as? VNewProfileViewController)?.user?.id != userId else {
            finish(result: .success())
            return
        }
        
        guard
            let profileViewController = dependencyManager.userProfileViewController(withRemoteID: userId),
            let originViewController = originViewController
        else {
            let error = NSError(domain: "ShowProfileOperation", code: -1, userInfo: nil)
            finish(result: .failure(error))
            return
        }
        
        if let originViewController = originViewController as? UINavigationController {
            originViewController.pushViewController(profileViewController, animated: true) {
                finish(result: .success())
            }
        } else {
            originViewController.navigationController?.pushViewController(profileViewController, animated: true) {
                finish(result: .success())
            }
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
private final class ShowCloseUpOperation: AsyncOperation<Void> {
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
    
    override var executionQueue: Queue {
        return .main
    }
    
    override func execute(finish: (result: OperationResult<Void>) -> Void) {
        guard
            let childDependencyManager = displayModifier.dependencyManager.childDependencyForKey("closeUpView"),
            let originViewController = displayModifier.originViewController,
            let contentID = contentID ?? content?.id
        else {
            let error = NSError(domain: "ShowCloseUpOperation", code: -1, userInfo: nil)
            finish(result: .failure(error))
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
            originViewController.pushViewController(closeUpViewController, animated: animated) {
                finish(result: .success())
            }
        } else {
            originViewController.navigationController?.pushViewController(closeUpViewController, animated: animated) {
                finish(result: .success())
            }
        }
    }
}

/// Fetches a piece of content and shows a close up view containing it.
private final class ShowFetchedCloseUpOperation: AsyncOperation<Void> {
    private let displayModifier: ShowCloseUpDisplayModifier
    private var contentID: String
    
    init(contentID: String, displayModifier: ShowCloseUpDisplayModifier) {
        self.displayModifier = displayModifier
        self.contentID = contentID
        super.init()
    }
    
    override var executionQueue: Queue {
        return .main
    }
    
    override func execute(finish: (result: OperationResult<Void>) -> Void) {
        
        let displayModifier = self.displayModifier
        guard
            let userID = VCurrentUser.user?.remoteId.integerValue,
            let contentFetchURL = displayModifier.dependencyManager.contentFetchURL
        else {
            let error = NSError(domain: "ShowFetchedCloseUpOperation", code: -1, userInfo: nil)
            finish(result: .failure(error))
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
        finish(result: .success())
    }
}

// MARK: - Show Web Content

private final class ShowWebContentOperation: AsyncOperation<Void> {
    private let originViewController: UIViewController
    private let urlToFetchFrom: String
    private let dependencyManager: VDependencyManager
    private let configuration: ExternalLinkDisplayConfiguration
    
    init (originViewController: UIViewController, url: String, dependencyManager: VDependencyManager, configuration: ExternalLinkDisplayConfiguration) {
        self.originViewController = originViewController
        self.dependencyManager = dependencyManager
        self.configuration = configuration
        self.urlToFetchFrom = url
    }
    
    override var executionQueue: Queue {
        return .main
    }
    
    override func execute(finish: (result: OperationResult<Void>) -> Void) {
        
        //We show the navigation and dismiss button if the view controller is presented modally, 
        // since there would be no way to dimiss the view controller otherwise
        let viewController = WebContentViewController(shouldShowNavigationButtons: configuration.forceModal)
        
        let fetchOperation = WebViewHTMLFetchOperation(urlPath: urlToFetchFrom)
        fetchOperation.after(self).queue { [weak fetchOperation] results, error, cancelled in
            guard
                let htmlString = fetchOperation?.resultHTMLString where error == nil,
                let baseURL = fetchOperation?.publicBaseURL
            else {
                viewController.setFailure(with: error)
                return
            }
            
            viewController.load(htmlString, baseURL: baseURL)
        }
        
        viewController.automaticallyAdjustsScrollViewInsets = false
        viewController.edgesForExtendedLayout = .All
        viewController.extendedLayoutIncludesOpaqueBars = true
        viewController.title = configuration.title
        
        if let navigationController = (originViewController as? UINavigationController) ?? originViewController.navigationController where !configuration.forceModal {
            navigationController.pushViewController(viewController, animated: configuration.transitionAnimated) {
                finish(result: .success())
            }
        }
        else {
            let navigationController = UINavigationController(rootViewController: viewController)
            
            dependencyManager.applyStyleToNavigationBar(navigationController.navigationBar)
        
            originViewController.presentViewController(navigationController, animated: configuration.transitionAnimated) {
                finish(result: .success())
            }
        }
    }
}

// MARK: - Show VIP Flow Operation

private final class ShowVIPSubscriptionOperation: AsyncOperation<Void> {
    private let dependencyManager: VDependencyManager
    private let animated: Bool
    private let completion: VIPFlowCompletion?
    private weak var originViewController: UIViewController?
    
    required init(originViewController: UIViewController, dependencyManager: VDependencyManager, animated: Bool = true, completion: VIPFlowCompletion? = nil) {
        self.dependencyManager = dependencyManager
        self.originViewController = originViewController
        self.animated = animated
        self.completion = completion
    }
    
    override var executionQueue: Queue {
        return .main
    }
    
    override func execute(finish: (result: OperationResult<Void>) -> Void) {
        // Jump to success if current user is already VIP
        if VCurrentUser.user?.hasValidVIPSubscription == true {
            completion?(true)
            finish(result: .success())
            return
        }
        
        guard
            let originViewController = originViewController,
            let vipFlow = dependencyManager.templateValueOfType(VIPFlowNavigationController.self, forKey: "vipPaygateScreen") as? VIPFlowNavigationController
        else {
            finish(result: .cancelled)
            return
        }
        
        vipFlow.completionBlock = completion
        originViewController.presentViewController(vipFlow, animated: animated) {
            finish(result: .success())
        }
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
