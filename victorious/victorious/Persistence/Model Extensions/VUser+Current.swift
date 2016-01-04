//
//  VUser+Current.swift
//  victorious
//
//  Created by Patrick Lynch on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import CoreData

let kLastLoginTypeUserDefaultsKey = "com.getvictorious.VUserManager.LoginType"
let kAccountIdentifierDefaultsKey = "com.getvictorious.VUserManager.AccountIdentifier"

let kManagedObjectContextUserInfoCurrentUserKey = "com.victorious.Persstence.CurrentUser"

public extension VUser {
    
    /// Returns a `VUser` object from the provided managed object context's user info dictionary
    /// (for performance and conveninece reasons).  This method is thread safe, and will handle loading
    /// the user from the proper context depending on which thread it is invoked.
    static func currentUser( inManagedObjectContext managedObjectContext: NSManagedObjectContext ) -> VUser? {
        
        let persistentStore: PersistentStoreType = MainPersistentStore()
        guard let user = persistentStore.mainContext.userInfo[ kManagedObjectContextUserInfoCurrentUserKey ] as? VUser else {
            return nil
        }
        
        if managedObjectContext == persistentStore.mainContext {
            return user
            
        } else {
            let objectID = user.objectID
            return persistentStore.backgroundContext.v_performBlockAndWait { context in
                return context.objectWithID( objectID ) as? VUser
            }
        }
    }

    static func currentUser() -> VUser? {
        let persistentStore: PersistentStoreType = MainPersistentStore()
        return VUser.currentUser( inManagedObjectContext: persistentStore.mainContext )
    }
    
    /// Strips the current user of its "current" status.  `currentUser()` method will
    /// now return nil until a new user has been set as current using method `setAsCurrent()`.
    static func clearCurrentUser() {
        let persistentStore: PersistentStoreType = MainPersistentStore()
        persistentStore.mainContext.userInfo[ kManagedObjectContextUserInfoCurrentUserKey ] = nil
    }
    
    /// Sets the receiver as the current user returned in `currentUser()` method.  Any previous
    /// current user will lose its current status, as their can be only one.
    func setAsCurrentUser() {
        let persistentStore: PersistentStoreType = MainPersistentStore()
        persistentStore.mainContext.userInfo[ kManagedObjectContextUserInfoCurrentUserKey ] = self
    }
    
    func isCurrentUser() -> Bool {
        return self.isEqualToUser( VUser.currentUser() )
    }
}