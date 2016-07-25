//
//  VDependencyManager+VUserProfile.swift
//  victorious
//
//  Created by Vincent Ho on 5/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension VDependencyManager {
    
    static var userProfileViewComponentKey: String { return "userProfileScreen" }
    static var userKey: String { return "user" }
    static var userRemoteIdKey: String { return "remoteId" }
    
    func userProfileViewController(for user: VUser) -> UIViewController? {
        return templateValueOfType(
            VNewProfileViewController.self,
            forKey: VDependencyManager.userProfileViewComponentKey,
            withAddedDependencies: [VDependencyManager.userKey: user]
        ) as? UIViewController
    }
    
    func userProfileViewController(withRemoteID remoteID: NSNumber) -> UIViewController? {
        return templateValueOfType(
            VNewProfileViewController.self,
            forKey: VDependencyManager.userProfileViewComponentKey,
            withAddedDependencies: [VDependencyManager.userRemoteIdKey: remoteID]
        ) as? UIViewController
    }
}
