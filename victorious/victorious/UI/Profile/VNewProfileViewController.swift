//
//  VNewProfileViewController.swift
//  victorious
//
//  Created by Jarod Long on 3/31/16.
//  Copyright (c) 2016 Victorious. All rights reserved.
//

import UIKit

/// A view controller that displays the contents of a user's profile.
class VNewProfileViewController: UIViewController, VIPGateViewControllerDelegate, CustomAccessoryScreensKey {
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
    
    var dependencyManager: VDependencyManager?
    var user: VUser?
    
    // MARK: - Initializing
    
    init(dependencyManager: VDependencyManager) {
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
        
        updateUpgradeButton()
        
        fetchUser(using: dependencyManager)
        
        self.dependencyManager = dependencyManager
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
            upgradeButton.hidden = true
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: upgradeButton)
            
            if let navigationBar = navigationController?.navigationBar {
                upgradeButton.backgroundColor = navigationBar.tintColor
                upgradeButton.setTitleColor(navigationBar.barTintColor, forState: .Normal)
            }
        }
    }
    
    // MARK: - View events
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateUpgradeButton()
        
        if let dependencyManager = self.dependencyManager {
            v_addAccessoryScreensWithDependencyManager(dependencyManager)
        }
    }
    
    // MARK: - View controllers
    
    private let gridStreamController: GridStreamViewController<VNewProfileHeaderView>
    
    // MARK: - Views
    
    private let upgradeButton = UIButton(type: .System)
    
    // MARK: - Actions
    
    private dynamic func upgradeButtonWasPressed() {
        ShowVIPGateOperation(originViewController: self, dependencyManager: gridStreamController.dependencyManager).queue()
    }
    
    // MARK: - VIPGateViewControllerDelegate
    
    func vipGateViewController(vipGateViewController: VIPGateViewController, allowedAccess allowed: Bool) {
        updateUpgradeButton()
    }
    
    // MARK: - CustomAccessoryScreensKey
    
    func customAccessoryScreensKey() -> String {
        guard let user = self.user else {
            return ""
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
        
        upgradeButton.hidden = user.isCreator != true || VCurrentUser.user()?.isVIPSubscriber == true
        
        if let dependencyManager = self.dependencyManager {
            v_addAccessoryScreensWithDependencyManager(dependencyManager)
        }

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
