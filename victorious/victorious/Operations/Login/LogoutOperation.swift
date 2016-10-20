//
//  LogoutOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import FBSDKLoginKit
import Foundation
import VictoriousIOSSDK

class LogoutOperation: AsyncOperation<Void> {
    
    // MARK: - Initializing
    
    init(dependencyManager: VDependencyManager? = nil) {
        self.dependencyManager = dependencyManager
        super.init()
        qualityOfService = .userInitiated
    }
    
    // MARK: - Initializing
    
    private let dependencyManager: VDependencyManager?
    
    override var executionQueue: Queue {
        return .background
    }
    
    override func execute(_ finish: @escaping (_ result: OperationResult<Void>) -> Void) {
        guard VCurrentUser.user != nil else {
            // Cannot logout without a current (logged-in) user
            finish(.failure(NSError(domain: "LogoutOperation", code: -1, userInfo: [:])))
            return
        }
        
        RequestOperation(request: LogoutRequest()).queue { result in
            InterstitialManager.sharedInstance.clearAllRegisteredAlerts()
            
            UserDefaults.standard.removeObject(forKey: kLastLoginTypeUserDefaultsKey)
            UserDefaults.standard.removeObject(forKey: kAccountIdentifierDefaultsKey)
            
            VStoredLogin().clearLoggedInUserFromDisk()
            VStoredPassword().clearSavedPassword()
            FBSDKLoginManager().logOut()
            
            VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserDidLogOut)
            
            // And finally, clear the user.  Don't do this early because
            // some of the stuff above requires knowing the current user
            VCurrentUser.clear()
        }
    }
}
