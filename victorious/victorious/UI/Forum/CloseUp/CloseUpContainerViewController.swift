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
    static let likeViewFrame = CGRect(x: 0.0, y: 0.0, width: 44.0, height: 44.0)
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
            style: .done,
            target: self,
            action: #selector(share)
        )
    }()
    
    private lazy var overflowButton: UIBarButtonItem = {
        return UIBarButtonItem(
            image: self.dependencyManager.overflowIcon,
            style: .done,
            target: self,
            action: #selector(overflow)
        )
    }()

    private lazy var likeView: LikeView = {
        let likeView = LikeView(
            frame: Constants.likeViewFrame,
            textColor: self.dependencyManager.upvoteCountColor,
            alignment: .left,
            selectedIcon: self.dependencyManager.upvoteIconSelected,
            unselectedIcon: self.dependencyManager.upvoteIconUnselected
        )

        likeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleLike)))
        likeView.updateLikeStatus(self.content)

        return likeView
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
            updateContent(content: content)
        }
        
        closeUpView.delegate = self
        
        updateHeader()
        
        addChildViewController(gridStreamController)
        view.addSubview(gridStreamController.view)
        view.v_addFitToParentConstraints(toSubview: gridStreamController.view)
        gridStreamController.didMove(toParentViewController: self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(returnedFromBackground), name: .UIApplicationDidBecomeActive, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        dependencyManager.addBackground(toBackgroundHost: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dependencyManager.trackViewWillAppear(for: self)
        trackContentView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(enterLandscapeMode), name: .UIDeviceOrientationDidChange, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dependencyManager.trackViewWillDisappear(for: self)
        closeUpView.headerWillDisappear()
        
        NotificationCenter.default.removeObserver(self, name: .UIDeviceOrientationDidChange, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        closeUpView.headerDidAppear()
    }
    
    // MARK: - ContentCellTracker
    
    var sessionParameters: [AnyHashable: Any] {
        return [VTrackingKeyContentId: contentID]
    }
    
    private func trackContentView() {
        if let content = content, firstPresentation {
            let value = context?.value ?? ""
            trackView(.viewStart, showingContent: content, parameters: [VTrackingKeyContext:value])
            firstPresentation = false
        }
    }
    
    private func updateHeader() {
        guard let content = content else {
            return
        }
        
        likeView.updateLikeStatus(content)
        if content.isLikedByCurrentUser {
            likeView.backgroundColor = dependencyManager.upvoteIconSelectedBackgroundColor
            likeView.tintColor = dependencyManager.upvoteIconTint
        }
        else {
            likeView.backgroundColor = dependencyManager.upvoteIconUnselectedBackgroundColor
            likeView.tintColor = nil
        }

        if content.shareURL == nil {
            navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: likeView), overflowButton]
        }
        else {
            navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: likeView), shareButton, overflowButton]
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
    
    func closeUpView(_ closeUpView: CloseUpView, didSelectProfileForUserID userID: User.ID) {
        Router(originViewController: self, dependencyManager: dependencyManager).navigate(
            to: DeeplinkDestination(userID: userID),
            from: DeeplinkContext(value: DeeplinkContext.closeupView)
        )
    }
    
    func closeUpViewGridStreamDidUpdate(_ closeUpView: CloseUpView) {
        triggerCoachmark()
    }
    
    func closeUpView(_ closeUpView: CloseUpView, didSelectLinkURL url: URL) {
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
    
    func toggleLike() {
        guard
            let content = content,
            let contentID = content.id,
            let likeAPIPath = dependencyManager.contentLikeAPIPath,
            let unLikeAPIPath = dependencyManager.contentUnLikeAPIPath
        else {
            return
        }

        if !content.isLikedByCurrentUser {
            likeView.animateLike()
        }

        let toggleLikeOperation: SyncOperation<Void>? = content.isLikedByCurrentUser
                ? ContentUnupvoteOperation(apiPath: unLikeAPIPath, contentID: contentID)
                : ContentUpvoteOperation(apiPath: likeAPIPath, contentID: contentID)

        guard let operation = toggleLikeOperation else {
            return
        }

        operation.queue { [weak self] _ in
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
                            case .success(_), .failure(_): let _ = self?.navigationController?.popViewController(animated: true)
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
        if let barFrame = navigationController?.navigationBar.frame, identifier == "bump" {
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
            let mediaContentView = closeUpView.mediaContentView,
        
            UIDevice.current.orientation.isLandscape && presentedViewController == nil
        else {
            return
        }
        
        // Removing the previous height constraint to avoid layout constraint conflict warnings with the new height constraint on media content view in lightbox.
        // Its previous height anchor was constraint to a constant, which would stick around after being removed from the view hierarchy.
        if let heightConstraint = closeUpView.mediaContentHeightConstraint {
            mediaContentView.removeConstraint(heightConstraint)
        }
        
        let lightbox = LightBoxViewController(mediaContentView: mediaContentView)
        lightbox.modalTransitionStyle = .crossDissolve
        
        lightbox.willDismiss = { [weak self] in
            self?.closeUpView.closeUpContentContainerView?.addSubview(mediaContentView)
            self?.closeUpView.setNeedsUpdateConstraints()
        }
        
        lightbox.didDismiss = { [weak self] in
            self?.closeUpView.headerDidAppear()
        }
        
        present(lightbox, animated: true, completion: nil)
    }
}

private extension VDependencyManager {
    var upvoteCountFont: UIFont? {
        return font(forKey: "font.upvote.count.text") ?? UIFont(name: ".SFUIText-Regular", size: 12.0)
    }

    var upvoteCountColor: UIColor {
        return color(forKey: "color.upvote.count.text") ?? .white
    }

    var upvoteIconTint: UIColor? {
        return color(forKey: "color.text.actionButton")
    }
    
    var upvoteIconSelectedBackgroundColor: UIColor? {
        return color(forKey: "color.background.upvote.selected")
    }
    
    var upvoteIconUnselectedBackgroundColor: UIColor? {
        return color(forKey: "color.background.upvote.unselected")
    }
    
    var upvoteIconSelected: UIImage? {
        return image(forKey: "upvote_icon_selected")?.withRenderingMode(.alwaysTemplate)
    }
    
    var upvoteIconUnselected: UIImage? {
        return image(forKey: "upvote_icon_unselected")?.withRenderingMode(.alwaysTemplate)
    }
    
    var overflowIcon: UIImage? {
        return image(forKey: "more_icon")
    }
    
    var shareIcon: UIImage? {
        return image(forKey: "share_icon")
    }
    
    var contentFlagAPIPath: APIPath? {
        return networkResources?.apiPathForKey("contentFlagURL")
    }
    
    var contentDeleteAPIPath: APIPath? {
        return networkResources?.apiPathForKey("contentDeleteURL")
    }

    var contentLikeAPIPath: APIPath? {
        return networkResources?.apiPathForKey("contentUpvoteURL", macroReplacements: ["%%CONTEXT%%": "closeup_view"])
    }

    var contentUnLikeAPIPath: APIPath? {
        return networkResources?.apiPathForKey("contentUnupvoteURL", macroReplacements: ["%%CONTEXT%%": "closeup_view"])
    }
    
    var gridStreamDependencyManager: VDependencyManager? {
        return childDependencyForKey("gridStream")
    }
}
