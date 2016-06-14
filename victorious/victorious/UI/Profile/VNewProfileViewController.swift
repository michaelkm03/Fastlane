//
//  VNewProfileViewController.swift
//  victorious
//
//  Created by Jarod Long on 3/31/16.
//  Copyright (c) 2016 Victorious. All rights reserved.
//

import UIKit

/// A view controller that displays the contents of a user's profile.
class VNewProfileViewController: UIViewController, VIPGateViewControllerDelegate {
    // MARK: - Constants
    
    static let userAppearanceKey = "userAppearance"
    static let creatorAppearanceKey = "creatorAppearance"
    
    private static let upgradeButtonXPadding = CGFloat(12.0)
    private static let upgradeButtonCornerRadius = CGFloat(5.0)
    
    private let dependencyManager: VDependencyManager
    private var user: VUser?
    
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
            image: self.dependencyManager.upvoteIconUnselected,
            style: .Done,
            target: self,
            action: #selector(toggleUpvote)
        )
    }()
    
    // MARK: - Initializing
    
    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
        let userID = VNewProfileViewController.getUserID(forDependencyManager: dependencyManager)
        let header = VNewProfileHeaderView.newWithDependencyManager(dependencyManager)
        
        var configuration = GridStreamConfiguration()
        configuration.managesBackground = false
        
        gridStreamController = GridStreamViewController(dependencyManager: dependencyManager,
                                                        header: header,
                                                        content: nil,
                                                        configuration: configuration,
                                                        streamAPIPath: dependencyManager.streamAPIPath(forUserID: userID))
        
        super.init(nibName: nil, bundle: nil)
        
        // Applies a fallback background color while we fetch the user.
        view.backgroundColor = dependencyManager.colorForKey(VDependencyManagerBackgroundColorKey)
        
        addChildViewController(gridStreamController)
        view.addSubview(gridStreamController.view)
        view.v_addFitToParentConstraintsToSubview(gridStreamController.view)
        gridStreamController.didMoveToParentViewController(self)
        
        updateRightBarButtonItems()
        
        fetchUser(using: dependencyManager)
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported.")
    }
    
    // MARK: - View updating
    
    private func updateUpgradeButton() {
        if VCurrentUser.user()?.isVIPValid() == true {
            // FUTURE: When new upgrade button appearance fields are read from template, update appearance of upgradeButton here
        }
        else {
            upgradeButton.setTitle("UPGRADE", forState: .Normal)
            upgradeButton.addTarget(self, action: #selector(upgradeButtonWasPressed), forControlEvents: .TouchUpInside)
            upgradeButton.sizeToFit()
            upgradeButton.frame.size.width += VNewProfileViewController.upgradeButtonXPadding
            upgradeButton.layer.cornerRadius = VNewProfileViewController.upgradeButtonCornerRadius
            if let navigationBar = navigationController?.navigationBar {
                upgradeButton.backgroundColor = navigationBar.tintColor
                upgradeButton.setTitleColor(navigationBar.barTintColor, forState: .Normal)
            }
        }
    }
    
    private func updateRightBarButtonItems() {
        // Upgrade button
        updateUpgradeButton()
        
        // Upvote button
        if user?.isFollowedByCurrentUser == true {
            upvoteButton.image = dependencyManager.upvoteIconSelected
            upvoteButton.tintColor = dependencyManager.upvoteIconTint
        }
        else {
            upvoteButton.image = dependencyManager.upvoteIconUnselected
            upvoteButton.tintColor = nil
        }
        
        navigationItem.rightBarButtonItems = userIsVIPSubscriber()
            ? [upvoteButton]
            : [UIBarButtonItem(customView: upgradeButton), upvoteButton]
    }
    
    // MARK: - View events
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateRightBarButtonItems()
    }
    
    // MARK: - View controllers
    
    private let gridStreamController: GridStreamViewController<VNewProfileHeaderView>
    
    // MARK: - Views
    
    private let upgradeButton = UIButton(type: .System)
    
    // MARK: - Actions
    
    private dynamic func upgradeButtonWasPressed() {
        ShowVIPGateOperation(originViewController: self, dependencyManager: gridStreamController.dependencyManager).queue()
    }
    
    func toggleUpvote() {
        guard let user = user else {
            return
        }
        let userID = Int(user.id)
        
//        UserUpvoteToggleOperation(
//            userID: userID,
//            upvoteURL: dependencyManager.userUpvoteURL,
//            unupvoteURL: dependencyManager.userUnupvoteURL
//        ).queue { [weak self] _ in
//            self?.updateHeader()
//        }
    }
    
    func overflow() {
        // FUTURE: Implement overflow button
    }
    
    // MARK: - VIPGateViewControllerDelegate
    
    func vipGateViewController(vipGateViewController: VIPGateViewController, allowedAccess allowed: Bool) {
        updateUpgradeButton()
    }
    
    // MARK: - Managing the user
    
    private func fetchUser(using dependencyManager: VDependencyManager) {
        if let user = dependencyManager.templateValueOfType(VUser.self, forKey: VDependencyManager.userKey) as? VUser {
            setUser(user, using: dependencyManager)
        }
        else if let userRemoteID = dependencyManager.templateValueOfType(NSNumber.self, forKey: VDependencyManager.userRemoteIdKey) as? NSNumber {
            guard
                let apiPath = dependencyManager.networkResources?.userFetchAPIPath,
                let userInfoOperation = UserInfoOperation(userID: userRemoteID.integerValue, apiPath: apiPath)
            else {
                return
            }
            
            userInfoOperation.queue { [weak self] results, error, cancelled in
                self?.setUser(userInfoOperation.user, using: dependencyManager)
            }
        }
        else {
            setUser(VCurrentUser.user(), using: dependencyManager)
        }
    }
    
    private func setUser(user: VUser?, using dependencyManager: VDependencyManager) {
        guard let user = user else {
            assertionFailure("Failed to fetch user for profile view controller.")
            return
        }
        
        self.user = user
        
        gridStreamController.content = user
        
        let appearanceKey = user.isCreator?.boolValue ?? false ? VNewProfileViewController.creatorAppearanceKey : VNewProfileViewController.userAppearanceKey
        let appearanceDependencyManager = dependencyManager.childDependencyForKey(appearanceKey)
        appearanceDependencyManager?.addBackgroundToBackgroundHost(gridStreamController)
        
        updateRightBarButtonItems()
    }
    
    private static func getUserID(forDependencyManager dependencyManager: VDependencyManager) -> Int {
        if let user = dependencyManager.templateValueOfType(VUser.self, forKey: VDependencyManager.userKey) as? VUser {
            return user.remoteId.integerValue
        }
        else if let userRemoteID = dependencyManager.templateValueOfType(NSNumber.self, forKey: VDependencyManager.userRemoteIdKey) as? NSNumber {
            return userRemoteID.integerValue
        }
        else {
            let user = VCurrentUser.user()
            assert(user != nil, "User should not be nil")
            return user?.remoteId.integerValue ?? 0
        }
    }
    
    private func userIsVIPSubscriber() -> Bool {
        guard let currentUser = VCurrentUser.user() else {
            return false
        }
        return currentUser.isVIPValid()
    }
}

private extension VDependencyManager {
    var refreshControlColor: UIColor? {
        return colorForKey(VDependencyManagerMainTextColorKey)
    }
}

private extension VDependencyManager {
    func streamAPIPath(forUserID userID: Int) -> APIPath {
        guard var apiPath = apiPathForKey("streamURL") else {
            return APIPath(templatePath: "")
        }
        
        apiPath.queryParameters = [
            "user_id": "\(userID)"
        ]
        
        return apiPath
    }
}

private extension VDependencyManager {
    var userUpvoteURL: String {
        return networkResources?.stringForKey("userUpvoteURL") ?? ""
    }
    
    var userUnupvoteURL: String {
        return networkResources?.stringForKey("userUnupvoteURL") ?? ""
    }
    
    var userBlockURL: String {
        return networkResources?.stringForKey("userBlockURL") ?? ""
    }
    
    var userUnblockURL: String {
        return networkResources?.stringForKey("userUnblockURL") ?? ""
    }
    
    var upvoteIconTint: UIColor? {
        return colorForKey("color.text.actionButton")
    }
    
// TODO: REMOVE
    var upvoteIconSelected: UIImage? {
//        return imageForKey("upvote_icon_selected")?.imageWithRenderingMode(.AlwaysTemplate)
        return UIImage(named: "upvote_icon_selected")?.imageWithRenderingMode(.AlwaysTemplate)
    }
    
// TODO: REMOVE
    var upvoteIconUnselected: UIImage? {
//        return imageForKey("upvote_icon_unselected")?.imageWithRenderingMode(.AlwaysTemplate)
        return UIImage(named: "upvote_icon_unselected")?.imageWithRenderingMode(.AlwaysTemplate)
    }
    
    var overflowIcon: UIImage? {
        return imageForKey("more_icon")
    }
    
    var shareIcon: UIImage? {
        return imageForKey("share_icon")
    }
}
