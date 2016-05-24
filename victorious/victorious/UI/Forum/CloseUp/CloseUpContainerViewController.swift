//
//  CloseUpContainerViewController.swift
//  victorious
//
//  Created by Vincent Ho on 5/20/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class CloseUpContainerViewController: UIViewController, CloseUpViewDelegate {
    
    private let gridStreamController: GridStreamViewController<CloseUpView>
    private var dependencyManager: VDependencyManager
    
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
        return UIBarButtonItem(
            image: self.dependencyManager.upvoteIconSelected,
            style: .Done,
            target: self,
            action: #selector(toggleUpvote)
        )
    }()
    
    init(dependencyManager: VDependencyManager,
         content: VContent? = nil,
         streamAPIPath: String?) {
        self.dependencyManager = dependencyManager
        
        let header = CloseUpView.newWithDependencyManager(dependencyManager)
                
        let configuration = GridStreamConfiguration(
            sectionInset: UIEdgeInsets(top: 3, left: 0, bottom: 3, right: 0),
            interItemSpacing: CGFloat(3),
            cellsPerRow: 3,
            allowsForRefresh: false,
            managesBackground: true
        )
        
        gridStreamController = GridStreamViewController<CloseUpView>.newWithDependencyManager(
            dependencyManager,
            header: header,
            content: content,
            configuration: configuration,
            streamAPIPath: streamAPIPath
        )
        
        super.init(nibName: nil, bundle: nil)
        
        header.delegate = self
        
        updateHeaderForContent(content)
                
        addChildViewController(gridStreamController)
        view.addSubview(gridStreamController.view)
        view.v_addFitToParentConstraintsToSubview(gridStreamController.view)
        gridStreamController.didMoveToParentViewController(self)
    }
    
    func share() {
        
    }
    
    func toggleUpvote() {
        // ToggleUpvoteRequest
    }
    
    func overflow() {
        
    }
    
    private func updateHeaderForContent(content: VContent?) {
        guard let content = content else {
            return
        }
        
//        upvoteButton.image = content.islike
    }
    
    override func viewDidLoad() {
        /// Set up nav bar
        
        navigationItem.leftItemsSupplementBackButton = true
        navigationItem.leftBarButtonItems = [shareButton, overflowButton]
        navigationItem.rightBarButtonItem = upvoteButton
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported.")
    }
    
    func updateContent(content: VContent) {
        updateHeaderForContent(content)
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
    
    func didSelectFlagContentForContentID(contentID: Int) {
        let flag = ContentFlagOperation(contentID: "\(contentID)")
        let confirm = ConfirmDestructiveActionOperation(
            actionTitle: NSLocalizedString("Report/Flag", comment: ""),
            originViewController: self,
            dependencyManager: dependencyManager
        )
        
        confirm.before(flag)
        confirm.queue()
        flag.queue()

    }
    
    func didToggleUpvoteForContentID(contentID: Int) {
        
    }

}

private extension VDependencyManager {
    var upvoteIconSelected: UIImage? {
        return imageForKey("upvote_icon_selected")
    }
    
    var upvoteIconUnselected: UIImage? {
        return imageForKey("upvote_icon_unselected")
    }
    
    var overflowIcon: UIImage? {
        return imageForKey("more_icon")
    }
    
    var shareIcon: UIImage? {
        return imageForKey("share_icon")
    }
}

