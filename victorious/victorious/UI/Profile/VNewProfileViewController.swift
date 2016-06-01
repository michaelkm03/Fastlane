//
//  VNewProfileViewController.swift
//  victorious
//
//  Created by Jarod Long on 3/31/16.
//  Copyright (c) 2016 Victorious. All rights reserved.
//

import UIKit

/// A view controller that displays the contents of a user's profile.
class VNewProfileViewController: UIViewController {
    // MARK: - Constants
    
    static let userAppearanceKey = "userAppearance"
    static let creatorAppearanceKey = "creatorAppearance"
    
    private static let upgradeButtonXPadding = CGFloat(12.0)
    private static let upgradeButtonCornerRadius = CGFloat(5.0)
    
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
                                                        streamAPIPath: dependencyManager.streamAPIPath(forUserID: userID) ?? "")
        
        super.init(nibName: nil, bundle: nil)
        
        // Applies a fallback background color while we fetch the user.
        view.backgroundColor = dependencyManager.colorForKey(VDependencyManagerBackgroundColorKey)
        
        addChildViewController(gridStreamController)
        view.addSubview(gridStreamController.view)
        view.v_addFitToParentConstraintsToSubview(gridStreamController.view)
        gridStreamController.didMoveToParentViewController(self)
        
        upgradeButton.setTitle("UPGRADE", forState: .Normal)
        upgradeButton.addTarget(self, action: #selector(upgradeButtonWasPressed), forControlEvents: .TouchUpInside)
        upgradeButton.sizeToFit()
        upgradeButton.frame.size.width += VNewProfileViewController.upgradeButtonXPadding
        upgradeButton.layer.cornerRadius = VNewProfileViewController.upgradeButtonCornerRadius
        upgradeButton.hidden = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: upgradeButton)
        
        fetchUser(using: dependencyManager)
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported.")
    }
    
    // MARK: - View events
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let navigationBar = navigationController?.navigationBar {
            upgradeButton.backgroundColor = navigationBar.tintColor
            upgradeButton.setTitleColor(navigationBar.barTintColor, forState: .Normal)
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
    
    // MARK: - Managing the user
    
    private func fetchUser(using dependencyManager: VDependencyManager) {
        if let user = dependencyManager.templateValueOfType(VUser.self, forKey: VDependencyManager.userKey) as? VUser {
            setUser(user, using: dependencyManager)
        }
        else if let userRemoteID = dependencyManager.templateValueOfType(NSNumber.self, forKey: VDependencyManager.userRemoteIdKey) as? NSNumber {
            let userInfoOperation = UserInfoOperation(userID: userRemoteID.integerValue, apiPath: dependencyManager.userFetchAPIPath)
            
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
        
        gridStreamController.content = user
        
        let appearanceKey = user.isCreator?.boolValue ?? false ? VNewProfileViewController.creatorAppearanceKey : VNewProfileViewController.userAppearanceKey
        let appearanceDependencyManager = dependencyManager.childDependencyForKey(appearanceKey)
        appearanceDependencyManager?.addBackgroundToBackgroundHost(gridStreamController)
        
        upgradeButton.hidden = user.isCreator != true || VCurrentUser.user()?.isVIPSubscriber == true
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
    
    var userFetchAPIPath: String? {
        return stringForKey("userInfoURL")
    }
}

private extension VDependencyManager {
    func streamAPIPath(forUserID userID: Int) -> String? {
        guard var apiPath = stringForKey("streamURL") else {
            return nil
        }
        
        // TODO: Fix this properly.
        apiPath = VSDKURLMacroReplacement().urlByReplacingMacrosFromDictionary([
            "%%FROM_TIME%%": "XXXXXXXXXX",
            "%%TO_TIME%%": "YYYYYYYYYY"
        ], inURLString: apiPath)
        
        let urlComponents = NSURLComponents(string: apiPath)
        let queryItem = NSURLQueryItem(name: "user_id", value: "\(userID)" )
        urlComponents?.queryItems = [ queryItem ]
        
        if var path = urlComponents?.string {
            path = path.stringByReplacingOccurrencesOfString("XXXXXXXXXX", withString: "%%FROM_TIME%%")
            path = path.stringByReplacingOccurrencesOfString("YYYYYYYYYY", withString: "%%TO_TIME%%")
            return path
        }
        
        return nil
    }
}
