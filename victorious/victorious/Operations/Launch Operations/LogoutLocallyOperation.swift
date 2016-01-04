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
    
    private let persistentStore: PersistentStoreType = PersistentStoreSelector.mainPersistentStore
    
    required init(fromViewController: UIViewController, dependencyManager: VDependencyManager) {
        self.fromViewController = fromViewController
        self.dependencyManager = dependencyManager
        
        super.init()
        
        qualityOfService = .UserInitiated
    }
    
    override func start() {
        super.start()
        
        self.beganExecuting()
        
        // Show the login again once we're logged out
        let loginOperation = ShowLoginOperation(originViewController: fromViewController, dependencyManager: dependencyManager)
        loginOperation.queueAfter( self, queue: Operation.defaultQueue )
        
        // Perform a fire-and-forget remote log out with the server
        let remoteLogoutOperation = LogoutOperation()
        remoteLogoutOperation.queueAfter( self, queue: remoteLogoutOperation.defaultQueue )
        
        InterstitialManager.sharedInstance.clearAllRegisteredAlerts()
        
        VUser.clearCurrentUser()
        
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