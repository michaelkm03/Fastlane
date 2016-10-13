//
//  ForumViewController.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import VictoriousIOSSDK

private struct Constants {
    static let coachmarkDisplayDelay = 1.0
}

protocol ActiveFeedDelegate: class {
    var activeFeed: Feed { get }
}

/// A template driven .screen component that sets up, houses and mediates the interaction
/// between the Forum's required concrete implementations and abstract dependencies.
class ForumViewController: UIViewController, Forum, VBackgroundContainer, VFocusable, UploadManagerHost, ContentPublisherDelegate, CoachmarkDisplayer, ActiveFeedDelegate {
    private struct EndVIPButtonConfiguration {
        let title: String
        let titleColor: UIColor
        let titleFont: UIFont
        let backgroundColor: UIColor
        let confirmationTitle: String
        let confirmationBody: String
        let closeAPIPath: APIPath
    }
    
    @IBOutlet private weak var stageContainer: UIView!
    @IBOutlet private weak var stageViewControllerContainer: VPassthroughContainerView!
    @IBOutlet private weak var stageTouchView: UIView!
    @IBOutlet private weak var stageContainerHeight: NSLayoutConstraint! {
        didSet {
            stageContainerHeight.constant = 0.0
        }
    }
    @IBOutlet private weak var chatFeedContainer: VPassthroughContainerView!
        
    private lazy var closeButton: ImageOnColorButton? = {
       return self.dependencyManager.closeButton
    }()
    
    private lazy var endVIPButton: UIButton? = {
        guard let configuration = self.endVIPConfiguration else {
            return nil
        }
        
        let button = BackgroundButton(type: .system)
        button.addTarget(self, action: #selector(endVIPEvent), for: .touchUpInside)
        button.setTitle(configuration.title, for: .normal)
        button.titleLabel?.font = configuration.titleFont
        button.titleLabel?.textColor = configuration.titleColor
        button.backgroundColor = configuration.backgroundColor
        button.sizeToFit()

        return button
    }()
    
    private lazy var endVIPConfiguration: EndVIPButtonConfiguration? = {
        guard
            let configuration = self.dependencyManager.endVIPConfiguration,
            let title = configuration.endVIPTitle,
            let titleColor = configuration.endVIPTitleColor,
            let titleFont = configuration.endVIPTitleFont,
            let backgroundColor = configuration.endVIPBackgroundColor,
            let confirmationTitle = configuration.endVIPConfirmationTitle,
            let confirmationBody = configuration.endVIPConfirmationBody,
            let closeAPIPath = configuration.endVIPAPIPath
        else {
            return nil
        }
        
        return EndVIPButtonConfiguration(
            title: title,
            titleColor: titleColor,
            titleFont: titleFont,
            backgroundColor: backgroundColor,
            confirmationTitle: confirmationTitle,
            confirmationBody: confirmationBody,
            closeAPIPath: closeAPIPath
        )
    }()

    private var stageShrinkingAnimator: StageShrinkingAnimator?
    
    #if V_ENABLE_WEBSOCKET_DEBUG_MENU
        private lazy var debugMenuHandler: DebugMenuHandler = {
            return DebugMenuHandler(targetViewController: self)
        }()
    #endif

    private var navBarTitleView : ForumNavBarTitleView?
    
    // MARK: - Initialization
    
    class func new(withDependencyManager dependencyManager: VDependencyManager) -> ForumViewController {
        let forumVC: ForumViewController = ForumViewController.v_initialViewControllerFromStoryboard("Forum")
        forumVC.dependencyManager = dependencyManager
        return forumVC
    }
    
    override init(nibName: String?, bundle: Bundle?) {
        super.init(nibName: nibName, bundle: bundle)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        NotificationCenter.default.addObserver(self, selector: #selector(mainFeedFilterDidChange), name: NSNotification.Name(rawValue: RESTForumNetworkSource.updateStreamURLNotification), object: nil)
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
    
    func receive(_ event: ForumEvent) {
        switch event {
            case .websocket(let websocketEvent):
                switch websocketEvent {
                    case .disconnected(_) where isViewLoaded:
                        let alert = Alert(title: NSLocalizedString("Reconnecting...", comment: "Reconnecting to server."), type: .reconnectingError)
                        InterstitialManager.sharedInstance.receive(alert)
                    default:
                        break
                }
            case .chatUserCount(let userCount):
                // A chat user count message is the only confirmed way of knowing that the connection is open, since our backend always accepts our connection before validating everything is ok.
                InterstitialManager.sharedInstance.dismissCurrentInterstitial(of: .reconnectingError)
                navBarTitleView?.activeUserCount = userCount.userCount
            case .closeVIP():
                onClose(sender: nil)
            case .refreshStage(_):
                triggerCoachmark()
            case .setOptimisticPostingEnabled(let enabled):
                publisher?.optimisticPostingEnabled = enabled
            default:
                break
        }
    }
    
    func send(_ event: ForumEvent) {
        switch event {
            case .sendContent(let content): publish(content: content)
            default: break
        }
        
        nextSender?.send(event)
    }
    
    // MARK: - Publishing
    
    private var publisher: ContentPublisher?
    
    /// Encapsulates information about the currently active feed
    var activeFeed = Feed(roomID: nil) {
        didSet {
            broadcast(.activeFeedChanged)
        }
    }
    
    private func publish(content: Content) {
        guard let width = chatFeed?.collectionView.frame.width else {
            return
        }
        
        publisher?.publish(content, withWidth: width, toChatRoomWithID: activeFeed.roomID)
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

    private(set) var chatFeedContext: DeeplinkContext = DeeplinkContext(value: DeeplinkContext.mainFeed)

    private dynamic func mainFeedFilterDidChange(notification: NSNotification) {
        let selectedItem = notification.userInfo?["selectedItem"] as? ListMenuSelectedItem
        chatFeedContext = selectedItem?.context ?? DeeplinkContext(value: DeeplinkContext.mainFeed)
        activeFeed = Feed(roomID: selectedItem?.chatRoomID)
    }

    func setStageHeight(_ value: CGFloat) {
        stageContainerHeight.constant = value
        UIView.performWithoutAnimation() {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - UploadManagerHost
    
    var uploadProgressViewController: VUploadProgressViewController?
    
    func addUploadManagerToViewController(_ viewController: UIViewController, topInset: CGFloat) {
        UploadManagerHelper.addUploadManagerToViewController(viewController, topInset: topInset)
    }
    
    func uploadProgressViewController(_ upvc: VUploadProgressViewController!, isNowDisplayingThisManyUploads uploadCount: Int) {
        updateUploadProgressViewControllerVisibility()
    }
    
    private func updateUploadProgressViewControllerVisibility() {
        guard let uploadProgressViewController = uploadProgressViewController else {
            return
        }
        
        if uploadProgressViewController.numberOfUploads > 0 {
            uploadProgressViewController.view.isHidden = false
        }
    }
    
    // MARK: - VBackgroundContainer
    
    func backgroundContainerView() -> UIView {
        return view
    }
    
    // MARK: - UIViewController
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        if let navBarTitleView = navBarTitleView {
            navigationItem.titleView = navBarTitleView
        }
        navBarTitleView?.sizeToFit()
        dependencyManager.trackViewWillAppear(for: self)
        #if V_ENABLE_WEBSOCKET_DEBUG_MENU
            if let webSocketForumNetworkSource = forumNetworkSource as? WebSocketForumNetworkSource,
                let navigationController = navigationController {
                let type = DebugMenuType.webSocket(messageContainer: webSocketForumNetworkSource.webSocketMessageContainer)
                debugMenuHandler.setupCurrentDebugMenu(debugMenuType: type, targetView: navigationController.navigationBar)
            }
        #endif
        
        BadgeCountManager.shared.fetchBadgeCount(for: .unreadNotifications)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addUploadManagerToViewController(self, topInset: topLayoutGuide.length)
        updateUploadProgressViewControllerVisibility()
        
        // Remove this once the way to animate the workspace in and out from forum has been figured out
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        composer?.dismissKeyboard(animated)
        dependencyManager.trackViewWillDisappear(for: self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        publisher = ContentPublisher(dependencyManager: dependencyManager.networkResources ?? dependencyManager)
        publisher?.delegate = self
        
        stageShrinkingAnimator = StageShrinkingAnimator(
            stageContainer: stageContainer,
            stageTouchView: stageTouchView,
            stageViewControllerContainer: stageViewControllerContainer,
            delegate: stage
        )
        stageShrinkingAnimator?.shouldHideKeyboardHandler = { [weak self] in
            self?.view.endEditing(true)
        }
        
        chatFeed?.nextSender = self
        //Initialize the title view. This will later be resized in the viewWillAppear, once it has actually been added to the navigation stack
        navBarTitleView = ForumNavBarTitleView(dependencyManager: self.dependencyManager, frame: CGRect(x: 0, y: 0, width: 80, height: 45))
        navigationController?.navigationBar.barStyle = .black
        if let button = closeButton {
            button.addTarget(self, action: #selector(onClose), for: .touchUpInside)
            button.sizeToFit()
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        }
        
        if let endVIPButton = endVIPButton, VCurrentUser.user?.accessLevel.isCreator == true {
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: endVIPButton)
        }
        
        updateStyle()
        
        if let forumNetworkSource = dependencyManager.forumNetworkSource {
            // Add the network source as the next responder in the FEC.
            nextSender = forumNetworkSource
            
            // Inject ourselves into the child receiver list in order to link the chain together.
            forumNetworkSource.addChildReceiver(self)
            
            self.forumNetworkSource = forumNetworkSource
        }
    }
    
    private dynamic func endVIPEvent() {
        guard let configuration = self.endVIPConfiguration else {
            return
        }
        
        let alertController = UIAlertController(
            title: configuration.confirmationTitle,
            message: configuration.confirmationBody,
            preferredStyle: .alert
        )
        let cancel = UIAlertAction(
            title: NSLocalizedString("Cancel", comment: "Cancel closing the VIP Event"),
            style: .default,
            handler: nil
        )
        alertController.addAction(cancel)
        
        let confirm = UIAlertAction(
            title: NSLocalizedString("Yes", comment: "Confirm closing the VIP Event"),
            style: .destructive
        ) { _ in
            self.confirmCloseVIPEvent()
        }
        alertController.addAction(confirm)
        
        present(alertController, animated: true)
    }
    
    private func confirmCloseVIPEvent() {
        guard
            let configuration = self.endVIPConfiguration,
            let request = EndVIPEventRequest(apiPath: configuration.closeAPIPath)
        else {
            return
        }
        
        RequestOperation(request: request).queue()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        let destination = segue.destination
        
        if let stage = destination as? Stage {
            stage.dependencyManager = dependencyManager.stageDependency
            stage.delegate = self
            self.stage = stage
            
        } else if let chatFeed = destination as? ChatFeed {
            chatFeed.dependencyManager = dependencyManager.chatFeedDependency
            chatFeed.chatFeedDelegate = self
            chatFeed.activeFeedDelegate = self
            self.chatFeed = chatFeed
        
        } else if let composer = destination as? Composer {
            composer.composerDelegate = self
            composer.dependencyManager = dependencyManager.composerDependency
            composer.activeFeedDelegate = self
            self.composer = composer
        
        } else {
            // Hide any embedded container views from which a component could not be loaded
            destination.view.superview?.isHidden = true
        }
    }
    
    // MARK: - Actions
    
    @objc private func onClose(sender: UIButton?) {
        if sender != nil {
            closeButton?.dependencyManager?.trackButtonEvent(.tap)
        }
        
        navigationController?.dismiss(animated: true)

        // Close connection to network source when we close the forum.
        forumNetworkSource?.tearDown()

        forumNetworkSource?.removeChildReceiver(self)
    }
    
    private func updateStyle() {
        guard isViewLoaded else {
            return
        }
        
        title = dependencyManager.title
        dependencyManager.applyStyle(to: self.navigationController?.navigationBar)
        navigationController?.navigationBar.isTranslucent = false
        dependencyManager.applyStyle(to: navigationController?.navigationBar)
        
        dependencyManager.addBackground(toBackgroundHost: self)
    }

    @IBAction private func tappedOnStage(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    // MARK: - Content action sheet
    
    private func showActionSheet(forContent chatFeedContent: ChatFeedContent) {
        guard let chatFeedDependencyManager = dependencyManager.chatFeedDependency else {
            return
        }
        
        if let alertController = UIAlertController(actionsFor: chatFeedContent.content, dependencyManager: chatFeedDependencyManager, completion: { [weak self] action in
            switch action {
                case .delete, .flag: self?.chatFeed?.remove(chatFeedContent)
                case .like, .unlike: self?.chatFeed?.collectionView.reloadData()
                case .cancel: break
            }
        }) {
            present(alertController, animated: true)
        }
    }
    
    // MARK: - ChatFeedDelegate
    
    func chatFeed(_ chatFeed: ChatFeed, didLongPress chatFeedContent: ChatFeedContent) {
        showActionSheet(forContent: chatFeedContent)
    }

    func chatFeed(_ chatFeed: ChatFeed, didToggleLikeFor content: ChatFeedContent, completion: @escaping (() -> Void)) {
        guard
            let contentID = content.content.id,
            let likeKey = dependencyManager.contentLikeKey,
            let unLikeKey = dependencyManager.contentUnLikeKey
        else {
            return
        }

        let context = chatFeedContext.value ?? "chat_feed"
        let isLikedByCurrentUser = content.content.isLikedByCurrentUser
        let likeAPIPath = APIPath(templatePath: likeKey, macroReplacements: ["%%CONTEXT%%": context, "%%ROOM_ID%%": activeFeed.roomID ?? ""])
        let unLikeAPIPath = APIPath(templatePath: unLikeKey, macroReplacements: ["%%CONTEXT%%": context, "%%ROOM_ID%%": activeFeed.roomID ?? ""])

        let toggleLikeOperation: SyncOperation<Void>? = isLikedByCurrentUser
            ? ContentUnupvoteOperation(apiPath: unLikeAPIPath, contentID: contentID)
            : ContentUpvoteOperation(apiPath: likeAPIPath, contentID: contentID)

        guard let operation = toggleLikeOperation else {
            return
        }

        operation.queue { _ in
            completion()
        }
    }

    func chatFeed(_ chatFeed: ChatFeed, didScroll scrollView: UIScrollView) {
        stageShrinkingAnimator?.chatFeed(chatFeed, didScroll: scrollView)
    }
    
    func chatFeed(_ chatFeed: ChatFeed, willBeginDragging scrollView: UIScrollView) {
        stageShrinkingAnimator?.chatFeed(chatFeed, willBeginDragging: scrollView)
    }
    
    func chatFeed(_ chatFeed: ChatFeed, willEndDragging scrollView: UIScrollView, withVelocity velocity: CGPoint) {
        stageShrinkingAnimator?.chatFeed(chatFeed, willEndDragging: scrollView, withVelocity: velocity)
    }
    
    func chatFeed(_ chatFeed: ChatFeed, didSelectFailureButtonFor chatFeedContent: ChatFeedContent) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(
            UIAlertAction(
                title: NSLocalizedString("Try Again", comment: "Sending message failed. User taps this to try sending again"),
                style: .default,
                handler: { [weak self] alertAction in
                    self?.retryPublish(chatFeedContent: chatFeedContent)
                }
            )
        )
        
        alertController.addAction(
            UIAlertAction(
                title: NSLocalizedString("Delete", comment: ""),
                style: .destructive,
                handler: { [weak self] alertAction in
                    self?.delete(chatFeedContent)
                }
            )
        )
        
        alertController.addAction(
            UIAlertAction(
                title: NSLocalizedString("Cancel", comment: ""),
                style: .cancel,
                handler: nil
            )
        )
        present(alertController, animated: true)
    }
    
    func chatFeed(_ chatFeed: ChatFeed, didSelectReplyButtonFor chatFeedContent: ChatFeedContent) {
        guard let username = chatFeedContent.content.author?.username else {
            return
        }
        
        composer?.append("@\(username)")
        composer?.showKeyboard()
    }
    
    func publisher(for chatFeed: ChatFeed) -> ContentPublisher? {
        return publisher
    }
    
    // MARK: - ContentPublisherDelegate
    
    func contentPublisher(_ contentPublisher: ContentPublisher, didQueue content: ChatFeedContent) {
        chatFeed?.handleNewItems([], loadingType: .newer, newPendingContentCount: 1) { [weak self] in
            self?.chatFeed?.collectionView.scrollToBottom(animated: true)
        }
    }

    func contentPublisher(_ contentPublisher: ContentPublisher, didFailToSend content: ChatFeedContent) {
        guard let itemCount = chatFeed?.chatInterfaceDataSource.itemCount else {
            return
        }
        
        let pendingItems = contentPublisher.pendingItems(forChatRoomWithID: activeFeed.roomID)

        chatFeed?.collectionView.reloadItems(at: pendingItems.indices.map {
            IndexPath(item: itemCount - 1 - $0, section: 0)
        })
    }
    
    // MARK: - Content Post Failure Handling
    
    private func retryPublish(chatFeedContent: ChatFeedContent) {
        guard let dataSource = chatFeed?.chatInterfaceDataSource else {
            return
        }
        
        if let retriedIndex = publisher?.retryPublish(chatFeedContent) {
            let retriedIndexPath = NSIndexPath(item: dataSource.unstashedItems.count + retriedIndex, section: 0)
            chatFeed?.collectionView.reloadItems(at: [retriedIndexPath as IndexPath])
        }
    }
    
    private func delete(_ chatFeedContent: ChatFeedContent) {
        guard let dataSource = chatFeed?.chatInterfaceDataSource else {
            return
        }
        
        if let removedIndicies = publisher?.remove([chatFeedContent]) {
            let indexPaths = removedIndicies.map { NSIndexPath(item: dataSource.unstashedItems.count + $0, section: 0)}
            chatFeed?.collectionView.deleteItems(at: indexPaths as [IndexPath])
        }
    }

    // MARK: - ComposerDelegate

    func didSelectNavigationMenuItem(_ navigationMenuItem: VNavigationMenuItem) {
        navigationMenuItem.dependencyManager.trackButtonEvent(.tap, for: VDependencyManager.defaultTrackingKey, with:  activeFeed.roomID.map { ["%%ROOM_ID%%": $0] })
    }

    // MARK: - VFocusable
    
    var focusType: VFocusType = .none {
        didSet {
            view.isUserInteractionEnabled = focusType != .none
        }
    }
    
    // MARK: - Coachmark Displayer
    
    func highlightFrame(forIdentifier identifier: String) -> CGRect? {
        return nil
    }
}

private extension VDependencyManager {
    var title: String? {
        return string(forKey: "title.text")
    }
    
    var chatFeedDependency: VDependencyManager? {
        return childDependency(forKey: "chatFeed")
    }
    
    var composerDependency: VDependencyManager? {
        return childDependency(forKey: "composer")
    }
    
    var stageDependency: VDependencyManager? {
        return childDependency(forKey: "stage")
    }
    
    var closeButton: ImageOnColorButton? {
        return button(forKey: "close.button") as? ImageOnColorButton
    }
    
    var contentDeleteURL: String {
        return networkResources?.string(forKey: "contentDeleteURL") ?? ""
    }

    var contentLikeKey: String? {
        return networkResources?.string(forKey: "contentUpvoteURL")
    }

    var contentUnLikeKey: String? {
        return networkResources?.string(forKey: "contentUnupvoteURL")
    }
    
    // MARK: - End VIP Button
    
    var endVIPConfiguration: VDependencyManager? {
        return childDependency(forKey: "end.button.vip")
    }
    
    var endVIPTitle: String? {
        return string(forKey: "text.title")
    }
    
    var endVIPTitleColor: UIColor? {
        return color(forKey: "color.title")
    }
    
    var endVIPTitleFont: UIFont? {
        return font(forKey: "font.title")
    }
    
    var endVIPBackgroundColor: UIColor? {
        return color(forKey: "color.background")
    }
    
    var endVIPConfirmationTitle: String? {
        return string(forKey: "text.confirmation.title")
    }
    
    var endVIPConfirmationBody: String? {
        return string(forKey: "text.confirmation.body")
    }
    
    var endVIPAPIPath: APIPath? {
        return networkResources?.apiPath(forKey: "end.vip.event.URL")
    }
}
