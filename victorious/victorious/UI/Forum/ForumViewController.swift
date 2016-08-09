//
//  ForumViewController.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

private struct Constants {
    static let coachmarkDisplayDelay = 1.0
}

/// A template driven .screen component that sets up, houses and mediates the interaction
/// between the Forum's required concrete implementations and abstract dependencies.
class ForumViewController: UIViewController, Forum, VBackgroundContainer, VFocusable, UploadManagerHost, ContentPublisherDelegate, CoachmarkDisplayer {
    @IBOutlet private weak var stageContainer: UIView!
    @IBOutlet private weak var stageViewControllerContainer: VPassthroughContainerView!
    @IBOutlet private weak var stageTouchView: UIView!
    @IBOutlet private weak var stageContainerHeight: NSLayoutConstraint! {
        didSet {
            stageContainerHeight.constant = 0.0
        }
    }
    @IBOutlet private weak var chatFeedContainer: VPassthroughContainerView!

    private var stageShrinkingAnimator: StageShrinkingAnimator?
    
    #if V_ENABLE_WEBSOCKET_DEBUG_MENU
        private lazy var debugMenuHandler: DebugMenuHandler = {
            return DebugMenuHandler(targetViewController: self)
        }()
    #endif

    private var navBarTitleView : ForumNavBarTitleView?
    private var isDisplayingCoachmark = false
    
    // MARK: - Initialization
    
    class func newWithDependencyManager(dependencyManager: VDependencyManager) -> ForumViewController {
        let forumVC: ForumViewController = ForumViewController.v_initialViewControllerFromStoryboard("Forum")
        forumVC.dependencyManager = dependencyManager
        return forumVC
    }
    
    // MARK: - ForumEventReceiver
    
    var childEventReceivers: [ForumEventReceiver] {
        let children = [
            stage as? ForumEventReceiver,
            chatFeed as? ForumEventReceiver,
            composer as? ForumEventReceiver
        ]
        return children.flatMap { $0 }
    }
    
    func receive(event: ForumEvent) {
        switch event {
            case .websocket(let websocketEvent):
                switch websocketEvent {
                    case .disconnected(_) where isViewLoaded():
                        // FUTURE: fetch the localized string from a new node in the template, depending on what the error type is.
                        let alert = Alert(title: "Reconnecting to server...", type: .reconnectingError)
                        InterstitialManager.sharedInstance.receive(alert)
                    default:
                        break
                }
            case .chatUserCount(let userCount):
                // A chat user count message is the only confirmed way of knowing that the connection is open, since our backend always accepts our connection before validating everything is ok.
                InterstitialManager.sharedInstance.dismissCurrentInterstitial(of: .reconnectingError)
                navBarTitleView?.activeUserCount = userCount.userCount
            case .filterContent(let path):
                // FUTURE: the composer should listen to these events and hide itself so everything component in the forum handles it's own state
                // path will be nil for home feed, and non nil for filtered feed
                composer?.setComposerVisible(path == nil, animated: true)
            case .closeVIP():
                onClose()
            case .refreshStage(_):
                triggerCoachmark()
            case .setOptimisticPostingEnabled(let enabled):
                publisher?.optimisticPostingEnabled = enabled
            default:
                break
        }
    }
    
    func send(event: ForumEvent) {
        switch event {
            case .sendContent(let content): publish(content)
            default: break
        }
        
        nextSender?.send(event)
    }
    
    // MARK: - Publishing
    
    private var publisher: ContentPublisher?
    
    private func publish(content: ContentModel) {
        guard let width = chatFeed?.collectionView.frame.width else {
            return
        }
        
        publisher?.publish(content, withWidth: width)
    }

    // MARK: - ForumEventSender
    
    weak var nextSender: ForumEventSender?
    
    // MARK: - Forum protocol requirements
    
    var stage: Stage?
    var composer: Composer?
    var chatFeed: ChatFeed?
    var dependencyManager: VDependencyManager!
    var forumNetworkSource: ForumNetworkSource?

    func creationFlowPresenter() -> VCreationFlowPresenter? {
        return composer?.creationFlowPresenter
    }
    
    var originViewController: UIViewController {
        return self
    }
    
    func setStageHeight(value: CGFloat) {
        stageContainerHeight.constant = value
        view.layoutIfNeeded()
    }
    
    // MARK: - UploadManagerHost
    
    var uploadProgressViewController: VUploadProgressViewController?
    
    func addUploadManagerToViewController(viewController: UIViewController, topInset: CGFloat) {
        UploadManagerHelper.addUploadManagerToViewController(viewController, topInset: topInset)
    }
    
    func uploadProgressViewController(upvc: VUploadProgressViewController!, isNowDisplayingThisManyUploads uploadCount: Int) {
        updateUploadProgressViewControllerVisibility()
    }
    
    private func updateUploadProgressViewControllerVisibility() {
        guard let uploadProgressViewController = uploadProgressViewController else {
            return
        }
        
        if uploadProgressViewController.numberOfUploads > 0 {
            uploadProgressViewController.view.hidden = false
        }
    }
    
    // MARK: - VBackgroundContainer
    
    func backgroundContainerView() -> UIView {
        return view
    }
    
    // MARK: - UIViewController
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        if let navBarTitleView = navBarTitleView {
            navigationItem.titleView = navBarTitleView
        }
        navBarTitleView?.sizeToFit()
        #if V_ENABLE_WEBSOCKET_DEBUG_MENU
            if let webSocketForumNetworkSource = forumNetworkSource as? WebSocketForumNetworkSource,
                let navigationController = navigationController {
                let type = DebugMenuType.webSocket(messageContainer: webSocketForumNetworkSource.webSocketMessageContainer)
                debugMenuHandler.setupCurrentDebugMenu(type, targetView: navigationController.navigationBar)
            }
        #endif
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        addUploadManagerToViewController(self, topInset: topLayoutGuide.length)
        updateUploadProgressViewControllerVisibility()
        
        // Remove this once the way to animate the workspace in and out from forum has been figured out
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        publisher = ContentPublisher(dependencyManager: dependencyManager.networkResources ?? dependencyManager)
        publisher?.delegate = self
        
        stageShrinkingAnimator = StageShrinkingAnimator(
            stageContainer: stageContainer,
            stageTouchView: stageTouchView,
            stageViewControllerContainer: stageViewControllerContainer
        )
        stageShrinkingAnimator?.shouldHideKeyboardHandler = { [weak self] in
            self?.view.endEditing(true)
        }
        stageShrinkingAnimator?.interpolateAlongside = {[weak self] percentage in
            self?.stage?.overlayUIAlpha = 1 - percentage
        }
        
        chatFeed?.nextSender = self
        //Initialize the title view. This will later be resized in the viewWillAppear, once it has actually been added to the navigation stack
        navBarTitleView = ForumNavBarTitleView(dependencyManager: self.dependencyManager, frame: CGRect(x: 0, y: 0, width: 200, height: 45))
        navigationController?.navigationBar.barStyle = .Black
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: dependencyManager.exitButtonIcon,
            style: .Plain,
            target: self,
            action: #selector(onClose)
        )
        updateStyle()
        
        if let forumNetworkSource = dependencyManager.forumNetworkSource {
            // Add the network source as the next responder in the FEC.
            nextSender = forumNetworkSource
            
            // Inject ourselves into the child receiver list in order to link the chain together.
            forumNetworkSource.addChildReceiver(self)
            
            self.forumNetworkSource = forumNetworkSource
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        let destination = segue.destinationViewController
        
        if let stage = destination as? Stage {
            stage.dependencyManager = dependencyManager.stageDependency
            stage.delegate = self
            self.stage = stage
            
        } else if let chatFeed = destination as? ChatFeed {
            chatFeed.dependencyManager = dependencyManager.chatFeedDependency
            chatFeed.delegate = self
            self.chatFeed = chatFeed
        
        } else if let composer = destination as? Composer {
            composer.dependencyManager = dependencyManager.composerDependency
            composer.delegate = self
            self.composer = composer
        
        } else {
            // Hide any embedded container views from which a component could not be loaded
            destination.view.superview?.hidden = true
        }
    }
    
    // MARK: - Actions
    
    @objc private func onClose() {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)

        // Close connection to network source when we close the forum.
        forumNetworkSource?.tearDown()

        forumNetworkSource?.removeChildReceiver(self)
    }
    
    private func updateStyle() {
        guard isViewLoaded() else {
            return
        }
        
        title = dependencyManager.title
        dependencyManager.applyStyleToNavigationBar(self.navigationController?.navigationBar)
        navigationController?.navigationBar.translucent = false
        dependencyManager.applyStyleToNavigationBar(navigationController?.navigationBar)
        
        dependencyManager.addBackgroundToBackgroundHost(self)
    }

    @IBAction private func tappedOnStage(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    // MARK: - Content action sheet
    
    private func showActionSheet(forContent chatFeedContent: ChatFeedContent) {
        if let alertController = UIAlertController(actionsFor: chatFeedContent.content, dependencyManager: dependencyManager) {
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: - ChatFeedDelegate
    
    func chatFeed(chatFeed: ChatFeed, didLongPressContent chatFeedContent: ChatFeedContent) {
        showActionSheet(forContent: chatFeedContent)
    }
    
    func chatFeed(chatFeed: ChatFeed, didScroll scrollView: UIScrollView) {
        stageShrinkingAnimator?.chatFeed(chatFeed, didScroll: scrollView)
    }
    
    func chatFeed(chatFeed: ChatFeed, willBeginDragging scrollView: UIScrollView) {
        stageShrinkingAnimator?.chatFeed(chatFeed, willBeginDragging: scrollView)
    }
    
    func chatFeed(chatFeed: ChatFeed, willEndDragging scrollView: UIScrollView, withVelocity velocity: CGPoint) {
        stageShrinkingAnimator?.chatFeed(chatFeed, willEndDragging: scrollView, withVelocity: velocity)
    }
    
    func chatFeed(chatFeed: ChatFeed, didSelectFailureButtonForContent chatFeedContent: ChatFeedContent) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.addAction(
            UIAlertAction(
                title: NSLocalizedString("Try Again", comment: "Sending message failed. User taps this to try sending again"),
                style: .Default,
                handler: { [weak self] alertAction in
                    self?.retryPublish(chatFeedContent)
                }
            )
        )
        
        alertController.addAction(
            UIAlertAction(
                title: NSLocalizedString("Delete", comment: ""),
                style: .Destructive,
                handler: { [weak self] alertAction in
                    self?.delete(chatFeedContent)
                }
            )
        )
        
        alertController.addAction(
            UIAlertAction(
                title: NSLocalizedString("Cancel", comment: ""),
                style: .Cancel,
                handler: nil
            )
        )
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func publisher(for chatFeed: ChatFeed) -> ContentPublisher? {
        return publisher
    }
    
    // MARK: - ContentPublisherDelegate
    
    func contentPublisher(contentPublisher: ContentPublisher, didQueue content: ChatFeedContent) {
        chatFeed?.handleNewItems([], loadingType: .newer, newPendingContentCount: 1) { [weak self] in
            self?.chatFeed?.collectionView.scrollToBottom(animated: true)
        }
    }
    
    func contentPublisher(contentPublisher: ContentPublisher, didFailToSend content: ChatFeedContent) {
        guard let itemCount = chatFeed?.chatInterfaceDataSource.itemCount else {
            return
        }
        
        chatFeed?.collectionView.reloadItemsAtIndexPaths(contentPublisher.pendingItems.indices.map {
            NSIndexPath(forItem: itemCount - 1 - $0, inSection: 0)
        })
    }
    
    // MARK: - Content Post Failure Handling
    
    private func retryPublish(chatFeedContent: ChatFeedContent) {
        guard let dataSource = chatFeed?.chatInterfaceDataSource else {
            return
        }
        
        if let retriedIndex = publisher?.retryPublish(chatFeedContent) {
            let retriedIndexPath = NSIndexPath(forItem: dataSource.visibleItems.count + retriedIndex, inSection: 0)
            chatFeed?.collectionView.reloadItemsAtIndexPaths([retriedIndexPath])
        }
    }
    
    private func delete(chatFeedContent: ChatFeedContent) {
        guard let dataSource = chatFeed?.chatInterfaceDataSource else {
            return
        }
        
        if let removedIndicies = publisher?.remove([chatFeedContent]) {
            let indexPaths = removedIndicies.map { NSIndexPath(forItem: dataSource.visibleItems.count + $0, inSection: 0)}
            chatFeed?.collectionView.deleteItemsAtIndexPaths(indexPaths)
        }
    }
    
    // MARK: - VFocusable
    
    var focusType: VFocusType = .None {
        didSet {
            view.userInteractionEnabled = focusType != .None
        }
    }
    
    // MARK: - Coachmark Displayer
    
    func highlightFrame(forIdentifier identifier: String) -> CGRect? {
        return nil
    }
}

private extension VDependencyManager {
    
    var title: String? {
        return stringForKey("title.text")
    }
    
    var chatFeedDependency: VDependencyManager? {
        return childDependencyForKey("chatFeed")
    }
    
    var composerDependency: VDependencyManager? {
        return childDependencyForKey("composer")
    }
    
    var stageDependency: VDependencyManager? {
        return childDependencyForKey("stage")
    }
    
    var exitButtonIcon: UIImage? {
        return imageForKey("closeIcon") ?? UIImage(named: "x_icon") //Template is currently returning incorrect path, so use the close icon in the image assets
    }
    
    var contentDeleteURL: String {
        return networkResources?.stringForKey("contentDeleteURL") ?? ""
    }
}
