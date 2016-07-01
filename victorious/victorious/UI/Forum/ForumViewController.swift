//
//  ForumViewController.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

/// A template driven .screen component that sets up, houses and mediates the interaction
/// between the Forum's required concrete implementations and abstract dependencies.
class ForumViewController: UIViewController, Forum, VBackgroundContainer, VFocusable, PersistentContentCreator, UploadManagerHost {

    @IBOutlet private weak var stageContainer: UIView! {
        didSet {
            stageContainer.layer.shadowColor = UIColor.blackColor().CGColor
            stageContainer.layer.shadowRadius = 8.0
            stageContainer.layer.shadowOpacity = 0.75
            stageContainer.layer.shadowOffset = CGSize(width:0, height:2)
        }
    }
    
    @IBOutlet private weak var stageContainerHeight: NSLayoutConstraint! {
        didSet {
            stageContainerHeight.constant = 0.0
        }
    }

    #if V_ENABLE_WEBSOCKET_DEBUG_MENU
        private lazy var debugMenuHandler: DebugMenuHandler = {
            return DebugMenuHandler(targetViewController: self)
        }()
    #endif

    private var navBarTitleView : ForumNavBarTitleView?
    
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
                    case .disconnected(let webSocketError):
                        if isViewLoaded() {
                            v_showAlert(title: "Disconnected from chat server", message: "Reconnecting soon.\n(error: \(webSocketError))", completion: nil)
                        }
                    default:
                        break
                }
            case .chatUserCount(let userCount):
                navBarTitleView?.activeUserCount = userCount.userCount
            case .filterContent(let path):
                composer?.setComposerVisible(path == nil, animated: true)
            default:
                break
        }
    }
    
    func send(event: ForumEvent) {
        
        switch event {
        case .sendContent(let content):
            
            guard let networkResources = dependencyManager.networkResources else {
                let logMessage = "Didn't find a valid network resources dependency inside the forum!"
                assertionFailure(logMessage)
                v_log(logMessage)
                nextSender?.send(event)
                return
            }
            
            createPersistentContent(content, networkResourcesDependency: networkResources) { [weak self] error in
                
                if let validError = error,
                    let strongSelf = self {
                    
                    if let persistenceError = validError as? PersistentContentCreatorError where
                        persistenceError.isInvalidNetworkResourcesError {
                        //Encountered an error where the network resources were inadequate. This does NOT
                        //represent an error state that should be messaged to the user.
                    } else {
                        strongSelf.v_showDefaultErrorAlert()
                    }
                }
            }
        default:()
        }
        nextSender?.send(event)
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
        navigationController?.navigationBar.topItem?.titleView = navBarTitleView
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

        // Set up the network source if needed.
        forumNetworkSource?.setUpIfNeeded()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        dependencyManager.addBackgroundToBackgroundHost(self)
    }

    // MARK: - VFocusable
    
    var focusType: VFocusType = .None {
        didSet {
            view.userInteractionEnabled = focusType != .None
        }
    }
    
    // MARK: - VCoachmarkDisplayer
    
    func screenIdentifier() -> String! {
        return dependencyManager.stringForKey(VDependencyManagerIDKey)
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
}
