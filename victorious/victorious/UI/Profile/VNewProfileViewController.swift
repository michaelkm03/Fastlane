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
    
    private let gridStreamController: GridStreamViewController<VNewProfileHeaderView>
    
    init(dependencyManager: VDependencyManager) {
        let userID = VNewProfileViewController.getUserID(forDependencyManager: dependencyManager)
        
        let header = VNewProfileHeaderView.newWithDependencyManager(dependencyManager)
        gridStreamController = GridStreamViewController(dependencyManager: dependencyManager,
                                                        header: header,
                                                        content: nil,
                                                        streamAPIPath: dependencyManager.streamAPIPath(forUserID: userID) ?? "")
        
        super.init(nibName: nil, bundle: nil)
        
        addChildViewController(gridStreamController)
        view.addSubview(gridStreamController.view)
        view.v_addFitToParentConstraintsToSubview(gridStreamController.view)
        gridStreamController.didMoveToParentViewController(self)
        
        setUser(forDependencyManager: dependencyManager)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported.")
    }
    
    private func setUser(forDependencyManager dependencyManager: VDependencyManager) {
        if let user = dependencyManager.templateValueOfType(VUser.self, forKey: VDependencyManager.userKey) as? VUser {
            gridStreamController.content = user
        }
        else if let userRemoteID = dependencyManager.templateValueOfType(NSNumber.self, forKey: VDependencyManager.userRemoteIdKey) as? NSNumber {
            let userInfoOperation = UserInfoOperation(userID: userRemoteID.integerValue)
            
            userInfoOperation.queue { [weak self] results, error, cancelled in
                self?.gridStreamController.content = userInfoOperation.user
            }
        }
        else {
            gridStreamController.content = VCurrentUser.user()
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
    func streamAPIPath(forUserID userID: Int) -> String? {
        return stringForKey("streamURL")?.stringByReplacingOccurrencesOfString("%%USER_ID%%", withString: "\(userID)")
    }
}
