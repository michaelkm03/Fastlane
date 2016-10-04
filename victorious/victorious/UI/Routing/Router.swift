//
//  Router.swift
//  victorious
//
//  Created by Tian Lan on 6/27/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import SafariServices
import VictoriousIOSSDK

/// A Router object that is able to navigate to a deeplink destination in the app
struct Router {
    
    // MARK: - Initialization
    
    fileprivate weak var originViewController: UIViewController?
    fileprivate let dependencyManager: VDependencyManager

    init(originViewController: UIViewController, dependencyManager: VDependencyManager) {
        self.originViewController = originViewController
        self.dependencyManager = dependencyManager
    }
    
    // MARK: - API

    func navigate(to destination: DeeplinkDestination?, from context: DeeplinkContext?) {
        guard let destination = destination else {
            showError()
            return
        }
        
        switch destination {
            case .profile(let userID): showProfile(for: userID)
            case .closeUp(let contentWrapper): showCloseUpView(for: contentWrapper, from: context)
            case .vipForum: showVIPForum()
            case .vipSubscription: showVIPSubscription()
            case .externalURL(let url, let configuration): showWebView(for: url as URL, configuration: configuration)
        }
    }
    
    // MARK: - Private Helper Functions
    
    fileprivate func showCloseUpView(for contentWrapper: CloseUpContentWrapper, from context: DeeplinkContext?) {
        guard let originViewController = self.originViewController else { return }
        let displayModifier = ShowCloseUpDisplayModifier(dependencyManager: dependencyManager, originViewController: originViewController)

        switch contentWrapper {
            case .content(let content, let forceFetch):
                guard content.type.canBeShownInCloseUpView else {
                    return
                }

                checkForPermissionBeforeRouting(contentIsForVIPOnly: content.isVIPOnly) { success in
                    if success {
                        if !forceFetch {
                            ShowCloseUpOperation(content: content, displayModifier: displayModifier, context: context).queue()
                        }
                        else {
                            guard let contentID = content.id else {
                                assertionFailure("We are routing to a content with no ID")
                                return
                            }
                            ShowFetchedCloseUpOperation(contentID: contentID, displayModifier: displayModifier, context: context).queue()
                        }
                    }
                }
            case .contentID(let contentID):
                ShowFetchedCloseUpOperation(contentID: contentID, displayModifier: displayModifier, context: context).queue()
        }
    }

    fileprivate func showVIPForum() {
        guard let originViewController = self.originViewController else {
            return
        }
        
        checkForPermissionBeforeRouting(contentIsForVIPOnly: true) { success in
            if success {
                ShowForumOperation(originViewController: originViewController, dependencyManager: self.dependencyManager, showVIP: true, animated: true).queue()
            }
        }
    }
    
    fileprivate func showVIPSubscription(completion: ((_ success: Bool) -> Void)? = nil) {
        guard let originViewController = self.originViewController else {
            return
        }
        
        ShowVIPSubscriptionOperation(originViewController: originViewController, dependencyManager: dependencyManager, completion: completion).queue()
    }
    
    fileprivate func showProfile(for userID: User.ID) {
        guard let originViewController = self.originViewController else {
            return
        }
        ShowProfileOperation(originViewController: originViewController, dependencyManager: dependencyManager, userId: userID).queue()
    }
    
    fileprivate func showWebView(for url: URL, configuration: ExternalLinkDisplayConfiguration) {
        checkForPermissionBeforeRouting(contentIsForVIPOnly: configuration.isVIPOnly) { success in
            if success {
                guard url.isHTTPScheme else {
                    self.showError()
                    return
                }
                    
                if configuration.addressBarVisible {
                    let safariViewController = SFSafariViewController(url: url)
                    self.originViewController?.present(safariViewController, animated: true, completion: nil)
                }
                
                else if let originVC = self.originViewController {
                    ShowWebContentOperation(originViewController: originVC, url: url.absoluteString, dependencyManager: self.dependencyManager, configuration: configuration).queue()
                }
            }
        }
    }
    
    fileprivate func showError() {
        let title = NSLocalizedString("Missing Content", comment: "The title of the alert saying we can't find a piece of content")
        let message = NSLocalizedString("Missing Content Message", comment: "A deep linked content has a wrong destination URL that we can't navigate to")
        originViewController?.v_showAlert(title: title, message: message)
    }
    
    func checkForPermissionBeforeRouting(contentIsForVIPOnly isVIPOnly: Bool = false, completion: ((_ success: Bool) -> Void)? = nil) {
        guard let currentUser = VCurrentUser.user else {
            // If there's no current user, then we fail automatically if VIP is required since the user can't subscribe
            // if they're not logged in, and we succeed automatically if VIP is not required.
            completion?(!isVIPOnly)
            return
        }
        
        if isVIPOnly && !currentUser.hasValidVIPSubscription {
            showVIPSubscription(completion: completion)
        }
        else {
            completion?(true)
        }
    }
}

// MARK: - Show Forum

private final class ShowForumOperation: AsyncOperation<Void> {
    fileprivate let dependencyManager: VDependencyManager
    fileprivate let animated: Bool
    fileprivate let showVIP: Bool
    fileprivate weak var originViewController: UIViewController?
    
    required init(originViewController: UIViewController, dependencyManager: VDependencyManager, showVIP: Bool = false, animated: Bool = true) {
        self.dependencyManager = dependencyManager
        self.showVIP = showVIP
        self.originViewController = originViewController
        self.animated = animated
    }
    
    override var executionQueue: Queue {
        return .main
    }
    
    override func execute(_ finish: @escaping (_ result: OperationResult<Void>) -> Void) {

        let templateKey = showVIP ? "vipForum" : "forum"
        let templateValue = dependencyManager.templateValue(ofType: ForumViewController.self, forKey: templateKey)
        guard let viewController = templateValue as? ForumViewController else {
            let error = NSError(domain: "ShowForumOperation", code: -1, userInfo: nil)
            finish(.failure(error))
            return
        }
        
        let navigationController = UINavigationController(rootViewController: viewController)
        originViewController?.present(navigationController, animated: animated) {
            ///
            /// FUTURE:
            /// This HACK is added in order to avoid the other HACK related to the main feed going blank. 
            /// The VIP forum had no way of initializing it's network source since this was done only once
            /// per app launch for both of the Forums. More info in this ticket: https://jira.victorious.com/browse/IOS-5560
            ///
            if self.showVIP {
                viewController.forumNetworkSource?.setUpIfNeeded()
            }
            finish(.success())
        }
    }
}

// MARK: - Show Profile

private final class ShowProfileOperation: AsyncOperation<Void> {
    fileprivate let dependencyManager: VDependencyManager
    fileprivate weak var originViewController: UIViewController?
    fileprivate let userId: Int
    
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
    
    override func execute(_ finish: @escaping (_ result: OperationResult<Void>) -> Void) {
        
        // Check if already showing the a user's profile
        guard (originViewController as? VNewProfileViewController)?.user?.id != userId else {
            finish(.success())
            return
        }
        
        guard
            let profileViewController = dependencyManager.userProfileViewController(withRemoteID: NSNumber(value: userId)),
            let originViewController = originViewController
        else {
            let error = NSError(domain: "ShowProfileOperation", code: -1, userInfo: nil)
            finish(.failure(error))
            return
        }
        
        if let originViewController = originViewController as? UINavigationController {
            originViewController.pushViewController(profileViewController, animated: true) {
                finish(.success())
            }
        } else {
            originViewController.navigationController?.pushViewController(profileViewController, animated: true) {
                finish(.success())
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
    fileprivate let displayModifier: ShowCloseUpDisplayModifier
    fileprivate var content: Content?
    fileprivate var contentID: String?
    fileprivate var context: DeeplinkContext?
    fileprivate(set) var displayedCloseUpView: CloseUpContainerViewController?

    init(contentID: String, displayModifier: ShowCloseUpDisplayModifier, context: DeeplinkContext? = nil) {
        self.contentID = contentID
        self.displayModifier = displayModifier
        self.context = context
        super.init()
    }

    init(content: Content, displayModifier: ShowCloseUpDisplayModifier, context: DeeplinkContext? = nil) {
        self.displayModifier = displayModifier
        self.content = content
        self.context = context
        super.init()
    }
    
    override var executionQueue: Queue {
        return .main
    }
    
    override func execute(_ finish: @escaping (_ result: OperationResult<Void>) -> Void) {
        guard
            let childDependencyManager = displayModifier.dependencyManager.childDependency(forKey: "closeUpView"),
            let originViewController = displayModifier.originViewController,
            let contentID = contentID ?? content?.id
        else {
            let error = NSError(domain: "ShowCloseUpOperation", code: -1, userInfo: nil)
            finish(.failure(error))
            return
        }
        
        let apiPath = APIPath(templatePath: childDependencyManager.relatedContentURL, macroReplacements: [
            "%%CONTENT_ID%%": contentID,
            "%%CONTEXT%%" : childDependencyManager.context
            ])

        let closeUpViewController = CloseUpContainerViewController(
            dependencyManager: childDependencyManager,
            contentID: contentID,
            streamAPIPath: apiPath,
            context: context,
            content: content
        )
        displayedCloseUpView = closeUpViewController
        
        let animated = displayModifier.animated
        if let originViewController = originViewController as? UINavigationController {
            originViewController.pushViewController(closeUpViewController, animated: animated) {
                finish(.success())
            }
        } else {
            originViewController.navigationController?.pushViewController(closeUpViewController, animated: animated) {
                finish(.success())
            }
        }
    }
}

/// Fetches a piece of content and shows a close up view containing it.
private final class ShowFetchedCloseUpOperation: AsyncOperation<Void> {
    fileprivate let displayModifier: ShowCloseUpDisplayModifier
    fileprivate var contentID: String
    fileprivate var context: DeeplinkContext?

    init(contentID: String, displayModifier: ShowCloseUpDisplayModifier, context: DeeplinkContext? = nil) {
        self.displayModifier = displayModifier
        self.contentID = contentID
        self.context = context
        super.init()
    }
    
    override var executionQueue: Queue {
        return .main
    }
    
    override func execute(_ finish: @escaping (_ result: OperationResult<Void>) -> Void) {
        
        let displayModifier = self.displayModifier
        guard
            let userID = VCurrentUser.user?.id,
            let contentFetchAPIPath = displayModifier.dependencyManager.contentFetchAPIPath,
            let contentFetchOperation = ContentFetchOperation(
                apiPath: contentFetchAPIPath,
                currentUserID: String(userID),
                contentID: contentID
            )
        else {
            let error = NSError(domain: "ShowFetchedCloseUpOperation", code: -1, userInfo: nil)
            finish(.failure(error))
            return
        }
        
        // Set up ShowCloseUpOperation and chain it
        let showCloseUpOperation = ShowCloseUpOperation(contentID: contentID, displayModifier: displayModifier, context: context)
        let _ = showCloseUpOperation.rechainAfter(self)
        
        // Set up ContentFetchOperation and chain it
        let _ = contentFetchOperation.rechainAfter(showCloseUpOperation)
        
        // Queue operations. We queue the operations after setting up dependency graph for NSOperationQueue performance reasons.
        showCloseUpOperation.queue()
        
        contentFetchOperation.queue { result in
            guard let shownCloseUpView = showCloseUpOperation.displayedCloseUpView else {
                return
            }
            
            switch result {
                case .success(let content):
                    // Check for permissions before we continue to show the content
                    let router = Router(originViewController: shownCloseUpView, dependencyManager: displayModifier.dependencyManager)
                    router.checkForPermissionBeforeRouting(contentIsForVIPOnly: content.isVIPOnly) { success in
                        if success {
                            shownCloseUpView.updateContent(content: content)
                        }
                        else {
                            let _ = shownCloseUpView.navigationController?.popViewController(animated: true)
                        }
                    }
                
                case .failure(_), .cancelled:
                    shownCloseUpView.updateError()
            }
        }
        
        finish(.success())
    }
}

// MARK: - Show Web Content

private final class ShowWebContentOperation: AsyncOperation<Void> {
    fileprivate let originViewController: UIViewController
    fileprivate let urlToFetchFrom: String
    fileprivate let dependencyManager: VDependencyManager
    fileprivate let configuration: ExternalLinkDisplayConfiguration
    
    init (originViewController: UIViewController, url: String, dependencyManager: VDependencyManager, configuration: ExternalLinkDisplayConfiguration) {
        self.originViewController = originViewController
        self.dependencyManager = dependencyManager
        self.configuration = configuration
        self.urlToFetchFrom = url
    }
    
    override var executionQueue: Queue {
        return .main
    }
    
    override func execute(_ finish: @escaping (_ result: OperationResult<Void>) -> Void) {
        
        //We show the navigation and dismiss button if the view controller is presented modally, 
        // since there would be no way to dimiss the view controller otherwise
        let viewController = WebContentViewController(shouldShowNavigationButtons: configuration.forceModal, dependencyManager: dependencyManager)
        
        let request = WebViewHTMLFetchRequest(urlPath: urlToFetchFrom)
        let operation = RequestOperation(request: request)
        
        operation.after(self).queue { result in
            switch result {
                case .success(let htmlString):
                    viewController.load(htmlString, baseURL: request.publicBaseURL ?? NSURL() as URL)
                
                case .failure(_), .cancelled:
                    viewController.setFailure(with: result.error as? NSError)
            }
        }
        
        viewController.automaticallyAdjustsScrollViewInsets = false
        viewController.edgesForExtendedLayout = .all
        viewController.extendedLayoutIncludesOpaqueBars = true
        viewController.title = configuration.title
        
        if let navigationController = (originViewController as? UINavigationController) ?? originViewController.navigationController , !configuration.forceModal {
            navigationController.pushViewController(viewController, animated: configuration.transitionAnimated) {
                finish(.success())
            }
        }
        else {
            let navigationController = UINavigationController(rootViewController: viewController)
            
            dependencyManager.applyStyle(to: navigationController.navigationBar)
        
            originViewController.present(navigationController, animated: configuration.transitionAnimated) {
                finish(.success())
            }
        }
    }
}

// MARK: - Show VIP Flow Operation

private final class ShowVIPSubscriptionOperation: AsyncOperation<Void> {
    fileprivate let dependencyManager: VDependencyManager
    fileprivate let animated: Bool
    fileprivate let completion: VIPFlowCompletion?
    fileprivate weak var originViewController: UIViewController?
    
    required init(originViewController: UIViewController, dependencyManager: VDependencyManager, animated: Bool = true, completion: VIPFlowCompletion? = nil) {
        self.dependencyManager = dependencyManager
        self.originViewController = originViewController
        self.animated = animated
        self.completion = completion
    }
    
    override var executionQueue: Queue {
        return .main
    }
    
    override func execute(_ finish: @escaping (_ result: OperationResult<Void>) -> Void) {
        // Jump to success if current user is already VIP
        if VCurrentUser.user?.hasValidVIPSubscription == true {
            completion?(true)
            finish(.success())
            return
        }
        
        guard
            let originViewController = originViewController,
            let vipFlow = dependencyManager.templateValue(ofType: VIPFlowNavigationController.self, forKey: "vipPaygateScreen") as? VIPFlowNavigationController
        else {
            finish(.cancelled)
            return
        }
        
        vipFlow.completionBlock = completion
        originViewController.present(vipFlow, animated: animated) {
            finish(.success())
        }
    }
}

// MARK: - Dependency Manager Extensions 

private extension VDependencyManager {
    var relatedContentURL: String {
        return string(forKey: "streamURL") ?? ""
    }
    
    var context: String {
        return string(forKey: "related.content.context") ?? ""
    }
    
    var contentFetchAPIPath: APIPath? {
        return networkResources?.apiPath(forKey: "contentFetchURL")
    }
}

// MARK: - ContentType extensions

private extension ContentType {
    var canBeShownInCloseUpView: Bool {
        switch self {
            case .image, .gif, .video, .link: return true
            case .text, .sticker: return false
        }
    }
}
