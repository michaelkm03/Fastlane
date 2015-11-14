//
//  LogoutLocallyOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/13/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

class LogoutLocally: Operation {
    
    override init() {
        super.init()
        
        qualityOfService = .UserInitiated
    }
    
    override func start() {
        super.start()
        
        self.beganExecuting()
        
        let dataStore = PersistentStore.mainContext
        guard let currentUser = VUser.currentUser(inContext: dataStore) else {
            fatalError( "Cannot get current user." )
        }
        
        let remoteLogoutOperation = LogoutOperation( userIdentifier: currentUser.identifier )
        
        VUser.clearCurrentUser(inContext: dataStore)
        
        InterstitialManager.sharedInstance.clearAllRegisteredInterstitials()
        
        NSUserDefaults.standardUserDefaults().removeObjectForKey( kLastLoginTypeUserDefaultsKey )
        NSUserDefaults.standardUserDefaults().removeObjectForKey( kAccountIdentifierDefaultsKey )
        
        VStoredLogin().clearLoggedInUserFromDisk()
        VStoredPassword().clearSavedPassword()
        
        VTrackingManager.sharedInstance().trackEvent( VTrackingEventUserDidLogOut )
        VTrackingManager.sharedInstance().setValue(false, forSessionParameterWithKey:VTrackingKeyUserLoggedIn)
        
        NSNotificationCenter.defaultCenter().postNotificationName(kLoggedInChangedNotification, object: self)
        
        self.queueNext( remoteLogoutOperation, queue: Operation.defaultQueue )
        
        self.finishedExecuting()
    }
}