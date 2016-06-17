//
//  VNewProfileViewController.swift
//  victorious
//
//  Created by Jarod Long on 3/31/16.
//  Copyright (c) 2016 Victorious. All rights reserved.
//

import UIKit

/// A view controller that displays the contents of a user's profile.
class VNewProfileViewController: UIViewController, ConfigurableGridStreamHeaderDelegate, VIPGateViewControllerDelegate, AccessoryScreensKeyProvider {
    // MARK: - Constants
    
    static let userAppearanceKey = "userAppearance"
    static let creatorAppearanceKey = "creatorAppearance"
    
    private static let upgradeButtonXPadding = CGFloat(12.0)
    private static let upgradeButtonCornerRadius = CGFloat(5.0)
    private struct AccessoryScreensKeys {
        static let userOwn = "accessories.user.own"
        static let userOther = "accessories.user.other"
        static let userCreator = "accessories.user.creator"
        static let creatorOwn = "accessories.creator.own"
    }
    
    // MARK: Dependency Manager
    
    let dependencyManager: VDependencyManager
    
    // MARK: Model Data
    
    var user: VUser? {
        get {
            return gridStreamController.content
        }
    }
    
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
        header.delegate = self

        // Applies a fallback background color while we fetch the user.
        view.backgroundColor = dependencyManager.colorForKey(VDependencyManagerBackgroundColorKey)
        
        addChildViewController(gridStreamController)
        view.addSubview(gridStreamController.view)
        view.v_addFitToParentConstraintsToSubview(gridStreamController.view)
        gridStreamController.didMoveToParentViewController(self)
        
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
        
        var rightBarButtonItems:[UIBarButtonItem] = []
        if shouldShowUpgradeButton() {
            rightBarButtonItems.append(UIBarButtonItem(customView: upgradeButton))
        }
        if user?.id != VCurrentUser.user()?.id {
            rightBarButtonItems.append(upvoteButton)
            if user?.isCreator != true {
                rightBarButtonItems.append(overflowButton)
            }
        }

        // FUTURE: This should be coming from the template VDependencyManager+AccessoryScreens infrastructure
//        navigationItem.rightBarButtonItems = rightBarButtonItems
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
        
        UserUpvoteToggleOperation(
            userID: userID,
            upvoteAPIPath: dependencyManager.userUpvoteAPIPath,
            unupvoteAPIPath: dependencyManager.userUnupvoteAPIPath
        ).queue { [weak self] _ in
            self?.updateRightBarButtonItems()
        }
    }
    
    func overflow() {
        guard
            let isBlocked = user?.isBlockedByCurrentUser,
            let userID = user?.id
        else {
            return
        }
        
        let toggleBlockedOperation = UserBlockToggleOperation(
            userID: userID,
            blockAPIPath: dependencyManager.userBlockAPIPath,
            unblockAPIPath: dependencyManager.userUnblockAPIPath
        )
        
        let actionTitle = isBlocked
            ? NSLocalizedString("UnblockUser", comment: "")
            : NSLocalizedString("BlockUser", comment: "")
        let confirm = ConfirmDestructiveActionOperation(
            actionTitle: actionTitle,
            originViewController: self,
            dependencyManager: dependencyManager
        )
        confirm.before(toggleBlockedOperation)
        confirm.queue()
        toggleBlockedOperation.queue()
    }
    
    // MARK: - VIPGateViewControllerDelegate
    
    func vipGateViewController(vipGateViewController: VIPGateViewController, allowedAccess allowed: Bool) {
        updateUpgradeButton()
    }
    
    // MARK: - AccessoryScreensKeyProvider

    var accessoryScreensKey: String? {
        guard let user = self.user else {
            return nil
        }
        
        if user.isCurrentUser() {
            if user.accessLevel == .owner {
                return AccessoryScreensKeys.creatorOwn
            } else {
                return AccessoryScreensKeys.userOwn
            }
        } else {
            if user.accessLevel == .user {
                return AccessoryScreensKeys.userCreator
            } else {
                return AccessoryScreensKeys.userOther
            }
        }
    }
    
    // MARK: - Managing the user
    
    private func fetchUser(using dependencyManager: VDependencyManager) {
        if let user = dependencyManager.templateValueOfType(VUser.self, forKey: VDependencyManager.userKey) as? VUser {
            setUser(user, using: dependencyManager)
        }
        else if let userRemoteID = dependencyManager.templateValueOfType(NSNumber.self, forKey: VDependencyManager.userRemoteIdKey) as? NSNumber {
            fetchUser(withRemoteID: userRemoteID.integerValue)
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
        
        gridStreamController.content = user
        
        let appearanceKey = user.isCreator?.boolValue ?? false ? VNewProfileViewController.creatorAppearanceKey : VNewProfileViewController.userAppearanceKey
        let appearanceDependencyManager = dependencyManager.childDependencyForKey(appearanceKey)
        appearanceDependencyManager?.addBackgroundToBackgroundHost(gridStreamController)
        
        upgradeButton.hidden = user.isCreator != true || VCurrentUser.user()?.isVIPSubscriber == true
        
        v_addAccessoryScreensWithDependencyManager(dependencyManager)
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
    
    private func shouldShowUpgradeButton() -> Bool {
        return !userIsVIPSubscriber() && user?.isCreator == true
    }
    
    private func userIsVIPSubscriber() -> Bool {
        guard let currentUser = VCurrentUser.user() else {
            return false
        }
        return currentUser.isVIPValid()
    }
    
    // MARK: - ConfigurableGridStreamContainer
    
    func shouldRefresh() {
        guard let userID = user?.id else {
            return
        }
        fetchUser(withRemoteID: userID)
    }
    
    private func fetchUser(withRemoteID remoteID: Int) {
        guard
            let apiPath = dependencyManager.networkResources?.userFetchAPIPath,
            let userInfoOperation = UserInfoOperation(userID: remoteID, apiPath: apiPath)
        else {
            return
        }
        
        userInfoOperation.queue { [weak self] results, error, cancelled in
            guard let dependencyManager = self?.dependencyManager else {
                return
            }
            self?.setUser(userInfoOperation.user, using: dependencyManager)
        }
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
    var userUpvoteAPIPath: APIPath {
        guard let apiPath = networkResources?.apiPathForKey("userUpvoteURL") else {
            assertionFailure("Failed to retrieve main feed API path from dependency manager.")
            return APIPath(templatePath: "")
        }
        return apiPath
    }
    
    var userUnupvoteAPIPath: APIPath {
        guard let apiPath = networkResources?.apiPathForKey("userUnupvoteURL") else {
            assertionFailure("Failed to retrieve main feed API path from dependency manager.")
            return APIPath(templatePath: "")
        }
        return apiPath
    }
    
    var userBlockAPIPath: APIPath {
        guard let apiPath = networkResources?.apiPathForKey("userBlockURL") else {
            assertionFailure("Failed to retrieve main feed API path from dependency manager.")
            return APIPath(templatePath: "")
        }
        return apiPath
    }
    
    var userUnblockAPIPath: APIPath {
        guard let apiPath = networkResources?.apiPathForKey("userUnblockURL") else {
            assertionFailure("Failed to retrieve main feed API path from dependency manager.")
            return APIPath(templatePath: "")
        }
        return apiPath
    }
    
    var upvoteIconTint: UIColor? {
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
}
