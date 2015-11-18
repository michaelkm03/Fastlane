//
//  LogoutLocallyOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/13/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

class LogoutLocally: Operation {
    
    let fromViewController: UIViewController
    let dependencyManager: VDependencyManager
    
    required init(fromViewController: UIViewController, dependencyManager: VDependencyManager) {
        self.fromViewController = fromViewController
        self.dependencyManager = dependencyManager
        
        super.init()
        
        qualityOfService = .UserInitiated
    }
    
    override func start() {
        super.start()
        
        self.beganExecuting()
        
        let persistentStore = PersistentStore()
        guard let currentUser = VUser.currentUser(inContext: persistentStore.mainContext) else {
            fatalError( "Cannot get current user." )
        }
        
        // Show the login again once we're logged out
        let loginOperation = ShowLoginOperation(originViewController: fromViewController, dependencyManager: dependencyManager)
        self.queueNext( loginOperation, queue: Operation.defaultQueue )
        
        // Perform a fire-and-forget remote log out with the server
        let remoteLogoutOperation = LogoutOperation( userIdentifier: currentUser.identifier )
        self.queueNext( remoteLogoutOperation, queue: remoteLogoutOperation.defaultQueue )
        
        VUser.clearCurrentUser(inContext: persistentStore.mainContext)
        
        InterstitialManager.sharedInstance.clearAllRegisteredInterstitials()
        
        NSUserDefaults.standardUserDefaults().removeObjectForKey( kLastLoginTypeUserDefaultsKey )
        NSUserDefaults.standardUserDefaults().removeObjectForKey( kAccountIdentifierDefaultsKey )
        
        VStoredLogin().clearLoggedInUserFromDisk()
        VStoredPassword().clearSavedPassword()
        
        VTrackingManager.sharedInstance().trackEvent( VTrackingEventUserDidLogOut )
        VTrackingManager.sharedInstance().setValue(false, forSessionParameterWithKey:VTrackingKeyUserLoggedIn)
        
        NSNotificationCenter.defaultCenter().postNotificationName(kLoggedInChangedNotification, object: nil)
        
        self.finishedExecuting()
    }
}