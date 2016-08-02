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

class CloseUpContainerViewController: UIViewController, CloseUpViewDelegate, ContentCellTracker, CoachmarkDisplayer {
    private let gridStreamController: GridStreamViewController<CloseUpView>
    var dependencyManager: VDependencyManager!
    private var content: VContent? {
        didSet {
            updateAudioSessionCategory()
            trackContentView()
        }
    }
    private let contentID: Content.ID
    private var firstPresentation = true
    private let closeUpView: CloseUpView
    
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
    
    init(dependencyManager: VDependencyManager, contentID: String, content: ContentModel? = nil, streamAPIPath: APIPath) {
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
            allowsForRefresh: false,
            managesBackground: true
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
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        dependencyManager.trackViewWillAppear(self)
        trackContentView()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        dependencyManager.trackViewWillDisappear(self)
        closeUpView.headerWillDisappear()
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
            trackView(.viewStart, showingContent: content)
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
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: upvoteButton), shareButton, overflowButton]
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported.")
    }
    
    func updateError() {
        gridStreamController.setContent(nil, withError: true)
    }
    
    func updateContent(content: ContentModel) {
        guard let findOrCreateOperation = ContentFindOrCreateOperation(contentModel: content) else {
            return
        }
        
        findOrCreateOperation.queue() { [weak self] results, _, _ in
            guard
                let strongSelf = self,
                let content = results?.first as? VContent
            else {
                return
            }
            
            strongSelf.content = content
            strongSelf.updateHeader()
            strongSelf.gridStreamController.setContent(content, withError: false)
        }
    }
    
    // MARK: - CloseUpViewDelegate
    
    func didSelectProfileForUserID(userID: Int) {
        let router = Router(originViewController: self, dependencyManager: dependencyManager)
        let destination = DeeplinkDestination(userID: userID)
        router.navigate(to: destination)
    }
    
    func gridStreamDidUpdate() {
        triggerCoachmark()
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
        guard let content = content else {
            return
        }
        
        ContentUpvoteToggleOperation(
            contentID: content.v_remoteID,
            upvoteURL: dependencyManager.contentUpvoteURL,
            unupvoteURL: dependencyManager.contentUnupvoteURL
        ).queue { [weak self] _ in
            self?.updateHeader()
        }
    }
    
    func overflow() {
        let isCreatorOfContent = content?.author.id == VCurrentUser.user()?.id
        
        let flagOrDeleteOperation = isCreatorOfContent
            ? ContentDeleteOperation(contentID: contentID, contentDeleteURL: dependencyManager.contentDeleteURL)
            : ContentFlagOperation(contentID: contentID, contentFlagURL: dependencyManager.contentFlagURL)
        
        let actionTitle = isCreatorOfContent
            ? NSLocalizedString("DeletePost", comment: "Delete this user's post")
            : NSLocalizedString("ReportPost", comment: "Report this post")
        
        let confirm = ConfirmDestructiveActionOperation(
            actionTitle: actionTitle,
            originViewController: self,
            dependencyManager: dependencyManager
        )
        
        confirm.before(flagOrDeleteOperation)
        confirm.queue()
        flagOrDeleteOperation.queue { [weak self] _, _, cancelled in
            /// FUTURE: Update parent view controller to remove content
            if !cancelled {
                self?.navigationController?.popViewControllerAnimated(true)
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
    
    var contentFlagURL: String {
        return networkResources?.stringForKey("contentFlagURL") ?? ""
    }
    
    var contentDeleteURL: String {
        return networkResources?.stringForKey("contentDeleteURL") ?? ""
    }
    
    var contentUpvoteURL: String {
        return networkResources?.stringForKey("contentUpvoteURL") ?? ""
    }
    
    var contentUnupvoteURL: String {
        return networkResources?.stringForKey("contentUnupvoteURL") ?? ""
    }
}

private extension VDependencyManager {
    var gridStreamDependencyManager: VDependencyManager? {
        return childDependencyForKey("gridStream")
    }
}
