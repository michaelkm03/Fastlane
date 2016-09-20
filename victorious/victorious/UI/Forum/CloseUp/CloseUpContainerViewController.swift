//
//  CloseUpContainerViewController.swift
//  victorious
//
//  Created by Vincent Ho on 5/20/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

private struct Constants {
    static let leftRightSectionInset = CGFloat(0)
    static let topBottomSectionInset = CGFloat(3)
    static let interItemSpacing = CGFloat(3)
    static let cellsPerRow = 3
    static let estimatedBarButtonWidth: CGFloat = 60.0
    static let estimatedStatusBarHeight: CGFloat = 20.0
    static let navigationBarRightPadding: CGFloat = 10.0 
}

class CloseUpContainerViewController: UIViewController, CloseUpViewDelegate, ContentCellTracker, CoachmarkDisplayer, VBackgroundContainer {
    private let gridStreamController: GridStreamViewController<CloseUpView>
    var dependencyManager: VDependencyManager!
    private var content: Content? {
        didSet {
            updateAudioSessionCategory()
            trackContentView()
        }
    }
    private let contentID: Content.ID
    private var firstPresentation = true
    private let closeUpView: CloseUpView
    private var context: DeeplinkContext?
    
    private lazy var shareButton: UIBarButtonItem = {
        return UIBarButtonItem(
            image: self.dependencyManager.shareIcon,
            style: .Done,
            target: self,
            action: #selector(share)
        )
    }()
    
    private lazy var overflowButton: UIBarButtonItem = {
        return UIBarButtonItem(
            image: self.dependencyManager.overflowIcon,
            style: .Done,
            target: self,
            action: #selector(overflow)
        )
    }()
    
    private lazy var upvoteButton: UIButton = {
        let button = BackgroundButton(type: .System)
        button.addTarget(self, action: #selector(toggleUpvote), forControlEvents: .TouchUpInside)
        return button
    }()
    
    private func updateAudioSessionCategory() {
        if content?.type == .video {
            VAudioManager.sharedInstance().focusedPlaybackDidBegin(muted: false)
        }
    }
    
    // MARK: - Initialization

    init(dependencyManager: VDependencyManager, contentID: String, streamAPIPath: APIPath, context: DeeplinkContext? = nil, content: Content? = nil) {
        self.context = context
        self.dependencyManager = dependencyManager
        
        closeUpView = CloseUpView.newWithDependencyManager(dependencyManager)
                
        let configuration = GridStreamConfiguration(
            sectionInset: UIEdgeInsets(
                top: Constants.topBottomSectionInset,
                left: Constants.leftRightSectionInset,
                bottom: Constants.topBottomSectionInset,
                right: Constants.leftRightSectionInset
            ),
            interItemSpacing: Constants.interItemSpacing,
            cellsPerRow: Constants.cellsPerRow,
            allowsForRefresh: false
        )
        
        gridStreamController = GridStreamViewController<CloseUpView>(
            dependencyManager: dependencyManager.gridStreamDependencyManager ?? dependencyManager,
            header: closeUpView,
            content: content,
            configuration: configuration,
            streamAPIPath: streamAPIPath
        )
        self.contentID = contentID
        
        super.init(nibName: nil, bundle: nil)
        
        updateAudioSessionCategory()

        if let content = content {
            updateContent(content)
        }
        
        closeUpView.delegate = self
        
        updateHeader()
        
        addChildViewController(gridStreamController)
        view.addSubview(gridStreamController.view)
        view.v_addFitToParentConstraintsToSubview(gridStreamController.view)
        gridStreamController.didMoveToParentViewController(self)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(returnedFromBackground), name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        dependencyManager.addBackgroundToBackgroundHost(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        dependencyManager.trackViewWillAppear(self)
        trackContentView()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(enterLandscapeMode), name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        dependencyManager.trackViewWillDisappear(self)
        closeUpView.headerWillDisappear()
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        closeUpView.headerDidAppear()
    }
    
    // MARK: - ContentCellTracker
    
    var sessionParameters: [NSObject : AnyObject] {
        return [ VTrackingKeyContentId : contentID ]
    }
    
    private func trackContentView() {
        if let content = content where firstPresentation {
            let value = context?.value ?? ""
            trackView(.viewStart, showingContent: content, parameters: [VTrackingKeyContext:value])
            firstPresentation = false
        }
    }
    
    private func updateHeader() {
        guard let content = content else {
            return
        }
        
        upvoteButton.tintColor = UIColor.redColor()
        
        if content.isLikedByCurrentUser {
            upvoteButton.setImage(dependencyManager.upvoteIconSelected, forState: .Normal)
            upvoteButton.backgroundColor = dependencyManager.upvoteIconSelectedBackgroundColor
            upvoteButton.tintColor = dependencyManager.upvoteIconTint
        }
        else {
            upvoteButton.setImage(dependencyManager.upvoteIconUnselected, forState: .Normal)
            upvoteButton.backgroundColor = dependencyManager.upvoteIconUnselectedBackgroundColor
            upvoteButton.tintColor = nil
        }
        
        upvoteButton.sizeToFit()
        
        if content.shareURL == nil {
            navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: upvoteButton), overflowButton]
        }
        else {
            navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: upvoteButton), shareButton, overflowButton]
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported.")
    }
    
    func updateError() {
        gridStreamController.setContent(nil, withError: true)
    }
    
    func updateContent(content: Content) {
        self.content = content
        updateHeader()
        gridStreamController.setContent(content, withError: false)
    }
    
    // MARK: - VBackgroundContainer
    
    func backgroundContainerView() -> UIView {
        return view
    }
    
    // MARK: - CloseUpViewDelegate
    
    func closeUpView(closeUpView: CloseUpView, didSelectProfileForUserID userID: User.ID) {
        Router(originViewController: self, dependencyManager: dependencyManager).navigate(
            to: DeeplinkDestination(userID: userID),
            from: DeeplinkContext(value: DeeplinkContext.closeupView)
        )
    }
    
    func closeUpViewGridStreamDidUpdate(closeUpView: CloseUpView) {
        triggerCoachmark()
    }
    
    func closeUpView(closeUpView: CloseUpView, didSelectLinkURL url: NSURL) {
        Router(originViewController: self, dependencyManager: dependencyManager).navigate(
            to: DeeplinkDestination(url: url),
            from: DeeplinkContext(value: DeeplinkContext.closeupView)
        )
    }
    
    func share() {
        guard let content = content else {
            return
        }
        ShowShareContentOperation(
            originViewController: self,
            dependencyManager: dependencyManager,
            content: content
        ).queue()
    }
    
    func toggleUpvote() {
        guard
            let content = content,
            let contentID = content.id,
            let upvoteAPIPath = dependencyManager.contentUpvoteAPIPath,
            let unupvoteAPIPath = dependencyManager.contentUnupvoteAPIPath,
            let upvoteOperation: SyncOperation<Void> = content.isLikedByCurrentUser
                ? ContentUnupvoteOperation(apiPath: unupvoteAPIPath, contentID: contentID)
                : ContentUpvoteOperation(apiPath: upvoteAPIPath, contentID: contentID)
        else {
            return
        }
        
        upvoteOperation.queue { [weak self] _ in
            self?.updateHeader()
        }
    }
    
    func overflow() {
        let isCreatorOfContent = content?.wasCreatedByCurrentUser == true
        
        guard
            let deleteAPIPath = dependencyManager.contentDeleteAPIPath,
            let flagAPIPath = dependencyManager.contentFlagAPIPath,
            let flagOrDeleteOperation: SyncOperation<Void> = isCreatorOfContent
                ? ContentDeleteOperation(apiPath: deleteAPIPath, contentID: contentID)
                : ContentFlagOperation(apiPath: flagAPIPath, contentID: contentID)
        else {
            return
        }
        
        let actionTitle = isCreatorOfContent
            ? NSLocalizedString("DeletePost", comment: "Delete this user's post")
            : NSLocalizedString("ReportPost", comment: "Report this post")
        
        let confirm = ConfirmDestructiveActionOperation(
            actionTitle: actionTitle,
            originViewController: self,
            dependencyManager: dependencyManager
        )
        
        
        confirm.queue() { result in
            switch result {
                case .success:
                    flagOrDeleteOperation.queue { [weak self] result in
                        /// FUTURE: Update parent view controller to remove content
                        switch result {
                            case .success(_), .failure(_): self?.navigationController?.popViewControllerAnimated(true)
                            case .cancelled: break
                        }
                }
                case .failure, .cancelled:
                    break
            }
        }
    }
    
    // MARK: - Coachmark Displayer
    
    func highlightFrame(forIdentifier identifier: String) -> CGRect? {
        if let barFrame = navigationController?.navigationBar.frame where identifier == "bump" {
            return CGRect(
                    x: barFrame.width - Constants.estimatedBarButtonWidth - Constants.navigationBarRightPadding,
                    y: Constants.estimatedStatusBarHeight,
                    width: Constants.estimatedBarButtonWidth,
                    height: barFrame.height
            )
        }
        return nil
    }
    
    // MARK: - Notification Response
    
    private dynamic func returnedFromBackground() {
        updateAudioSessionCategory()
    }
    
    private dynamic func enterLandscapeMode() {
        guard
            UIDevice.currentDevice().orientation.isLandscape,
            let mediaContentView = closeUpView.mediaContentView
        else {
            return
        }
        
        // Removing the previous height constraint to avoid layout constraint conflict warnings with the new height constraint on media content view in lightbox.
        // Its previous height anchor was constraint to a constant, which would stick around after being removed from the view hierarchy.
        if let heightConstraint = closeUpView.mediaContentHeightConstraint {
            mediaContentView.removeConstraint(heightConstraint)
        }
        
        let lightbox = LightBoxViewController(mediaContentView: mediaContentView)
        lightbox.modalTransitionStyle = .CrossDissolve
        
        lightbox.willDismiss = { [weak self] in
            self?.closeUpView.closeUpContentContainerView?.addSubview(mediaContentView)
            self?.closeUpView.setNeedsUpdateConstraints()
        }
        
        lightbox.didDismiss = { [weak self] in
            self?.closeUpView.headerDidAppear()
        }
        
        presentViewController(lightbox, animated: true, completion: nil)
    }
}

private extension VDependencyManager {
    var upvoteIconTint: UIColor? {
        return colorForKey("color.text.actionButton")
    }
    
    var upvoteIconSelectedBackgroundColor: UIColor? {
        return colorForKey("color.background.upvote.selected")
    }
    
    var upvoteIconUnselectedBackgroundColor: UIColor? {
        return colorForKey("color.background.upvote.unselected")
    }
    
    var upvoteIconSelected: UIImage? {
        return imageForKey("upvote_icon_selected")?.imageWithRenderingMode(.AlwaysTemplate)
    }
    
    var upvoteIconUnselected: UIImage? {
        return imageForKey("upvote_icon_unselected")?.imageWithRenderingMode(.AlwaysTemplate)
    }
    
    var overflowIcon: UIImage? {
        return imageForKey("more_icon")
    }
    
    var shareIcon: UIImage? {
        return imageForKey("share_icon")
    }
    
    var contentFlagAPIPath: APIPath? {
        return networkResources?.apiPathForKey("contentFlagURL")
    }
    
    var contentDeleteAPIPath: APIPath? {
        return networkResources?.apiPathForKey("contentDeleteURL")
    }
    
    var contentUpvoteAPIPath: APIPath? {
        return networkResources?.apiPathForKey("contentUpvoteURL")
    }
    
    var contentUnupvoteAPIPath: APIPath? {
        return networkResources?.apiPathForKey("contentUnupvoteURL")
    }
    
    var gridStreamDependencyManager: VDependencyManager? {
        return childDependencyForKey("gridStream")
    }
}
