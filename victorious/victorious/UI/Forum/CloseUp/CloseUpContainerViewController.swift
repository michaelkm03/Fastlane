//
//  CloseUpContainerViewController.swift
//  victorious
//
//  Created by Vincent Ho on 5/20/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

private let leftRightSectionInset = CGFloat(0)
private let topBottomSectionInset = CGFloat(3)
private let interItemSpacing = CGFloat(3)
private let cellsPerRow = 3

class CloseUpContainerViewController: UIViewController, CloseUpViewDelegate, ContentCellTracker {
    private let gridStreamController: GridStreamViewController<CloseUpView>
    private var dependencyManager: VDependencyManager
    private var content: ContentModel? {
        didSet {
            trackContentView()
        }
    }
    private let contentID: String
    private var firstPresentation = true
    
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
    
    init(dependencyManager: VDependencyManager, contentID: String, content: ContentModel? = nil, streamAPIPath: APIPath) {
        self.dependencyManager = dependencyManager
        
        let header = CloseUpView.newWithDependencyManager(dependencyManager)
                
        let configuration = GridStreamConfiguration(
            sectionInset: UIEdgeInsets(
                top: topBottomSectionInset,
                left: leftRightSectionInset,
                bottom: topBottomSectionInset,
                right: leftRightSectionInset
            ),
            interItemSpacing: interItemSpacing,
            cellsPerRow: cellsPerRow,
            allowsForRefresh: false,
            managesBackground: true
        )
        
        gridStreamController = GridStreamViewController<CloseUpView>(
            dependencyManager: dependencyManager.gridStreamDependencyManager ?? dependencyManager,
            header: header,
            content: content,
            configuration: configuration,
            streamAPIPath: streamAPIPath
        )
        self.contentID = contentID
        self.content = content
        
        super.init(nibName: nil, bundle: nil)
        
        header.delegate = self
        
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
        self.content = content
        updateHeader()
        gridStreamController.setContent(content, withError: false)
    }
    
    // MARK: - CloseUpViewDelegate
    
    func didSelectProfileForUserID(userID: Int) {
        let router = Router(originViewController: self, dependencyManager: dependencyManager)
        let destination = DeeplinkDestination(userID: userID)
        router.navigate(to: destination)
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
        ContentUpvoteToggleOperation(
            contentID: contentID,
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
