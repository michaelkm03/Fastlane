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

class LogoutOperation: RemoteFetcherOperation {
    
    private var dependencyManager: VDependencyManager? = nil
    
    override init() {
        super.init()
        
        requiresAuthorization = false
        
        // Boost the priority of this operation
        self.qualityOfService = .UserInitiated
        
        // Before cleaning out current user data, prune the persistent store first,
        // and make the remote logout call to backend
        let pruneOperation = LogoutPrunePersistentStoreOperation()
        pruneOperation.before(self).queue()
        LogoutRemoteOperation().rechainAfter(pruneOperation).queue()
    }
    
    convenience init(dependencyManager: VDependencyManager) {
        self.init()
        self.dependencyManager = dependencyManager
    }
    
    override func main() {
        let currentUser: VUser? = dispatch_sync( dispatch_get_main_queue() ) {
            return VCurrentUser.user()
        }
        guard currentUser != nil else {
            // Cannot logout without a current (logged-in) user
            return
        }
        
        dispatch_sync( dispatch_get_main_queue() ) {
            
            InterstitialManager.sharedInstance.clearAllRegisteredAlerts()
            
            NSUserDefaults.standardUserDefaults().removeObjectForKey( kLastLoginTypeUserDefaultsKey )
            NSUserDefaults.standardUserDefaults().removeObjectForKey( kAccountIdentifierDefaultsKey )
            
            VStoredLogin().clearLoggedInUserFromDisk()
            VStoredPassword().clearSavedPassword()
            FBSDKLoginManager().logOut()
            
            VTrackingManager.sharedInstance().trackEvent( VTrackingEventUserDidLogOut )
            
            if let dependencyManager = self.dependencyManager,
               let forumNetworkSource = dependencyManager.forumNetworkSource { //Try to reset the network resource token
                forumNetworkSource.tearDown()
            }
        }
        
        // And finally, clear the user.  Don't do this early because
        // some of the stuff above requires knowing the current user
        VCurrentUser.clear()
    }
}

private class LogoutRemoteOperation: RemoteFetcherOperation, RequestOperation {
    
    let request: LogoutRequest! = LogoutRequest()
    
    override init() {
        super.init()
        
        requiresAuthorization = false
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: nil, onError: nil )
    }
}
