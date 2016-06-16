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

class CloseUpContainerViewController: UIViewController, CloseUpViewDelegate {
    
    private let gridStreamController: GridStreamViewController<CloseUpView>
    private var dependencyManager: VDependencyManager
    private var content: ContentModel?
    
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
    
    private lazy var upvoteButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: self.dependencyManager.upvoteIconUnselected,
            style: .Done,
            target: self,
            action: #selector(toggleUpvote)
        )
        return button
    }()
    
    init(dependencyManager: VDependencyManager,
         content: ContentModel? = nil,
         streamAPIPath: APIPath) {
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
        self.content = content
        
        super.init(nibName: nil, bundle: nil)
        
        header.delegate = self
        
        updateHeader()
                
        addChildViewController(gridStreamController)
        view.addSubview(gridStreamController.view)
        view.v_addFitToParentConstraintsToSubview(gridStreamController.view)
        gridStreamController.didMoveToParentViewController(self)
    }
    
    private func updateHeader() {
        guard let content = content else {
            return
        }
        
        if content.isLikedByCurrentUser {
            upvoteButton.image = dependencyManager.upvoteIconSelected
            upvoteButton.tintColor = dependencyManager.upvotedIconTint
        }
        else {
            upvoteButton.image = dependencyManager.upvoteIconUnselected
            upvoteButton.tintColor = nil
        }
        
        navigationItem.rightBarButtonItems = [upvoteButton, overflowButton, shareButton]
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported.")
    }
    
    func updateContent(content: ContentModel) {
        self.content = content
        updateHeader()
        gridStreamController.content = content
    }
    
    // MARK: - CloseUpViewDelegate
    
    func didSelectProfileForUserID(userID: Int) {
        ShowProfileOperation(
            originViewController: self,
            dependencyManager: dependencyManager,
            userId: userID
        ).queue()
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
        guard let contentID = content?.id else {
            return
        }
        ContentUpvoteToggleOperation(
            contentID: contentID,
            upvoteURL: dependencyManager.contentUpvoteURL,
            unupvoteURL: dependencyManager.contentUnupvoteURL
            ).queue() { [weak self] _ in
                self?.updateHeader()
        }
    }
    
    func overflow() {
        guard let contentID = content?.id else {
            return
        }
        
        let isCreatorOfContent = content?.author.id == VCurrentUser.user()?.id
        
        let flagOrDeleteOperation = isCreatorOfContent
            ? ContentDeleteOperation(contentID: contentID, contentDeleteURL: dependencyManager.contentDeleteURL)
            : ContentFlagOperation(contentID: contentID, contentFlagURL: dependencyManager.contentFlagURL)
        
        let actionTitle = isCreatorOfContent
            ? NSLocalizedString("DeleteButton", comment: "")
            : NSLocalizedString("Report/Flag", comment: "")
        
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
    var upvotedIconTint: UIColor? {
        return colorForKey("color.text.actionButton")
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
