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

class VCurrentUser: NSObject {
    static var persistentStore: PersistentStoreType = PersistentStoreSelector.defaultPersistentStore
    
    /// Returns a `VUser` object from the provided managed object context's user info dictionary
    /// (for performance and convenience reasons).  This method is thread safe, and will handle loading
    /// the user from the proper context depending on which thread it is invoked.
    static func user( inManagedObjectContext managedObjectContext: NSManagedObjectContext ) -> VUser? {
        
        let user: VUser? = persistentStore.mainContext.v_performBlockAndWait() { context in
            context.userInfo[ kManagedObjectContextUserInfoCurrentUserKey ] as? VUser
        }
        guard let userFromMainContext = user else {
            return nil
        }
        
        if managedObjectContext == persistentStore.mainContext {
            return userFromMainContext
            
        } else {
            return managedObjectContext.v_performBlockAndWait { context in
                return context.objectWithID( userFromMainContext.objectID ) as? VUser
            }
        }
    }
    
    static func user() -> VUser? {
        guard NSThread.currentThread().isMainThread else {
            assertionFailure( "Attempt to read current user from the persistent store's main context from a thread other than the main thread.  Use method `user(inManagedObjectcontext:)` and provide the context in which you are working." )
            return nil
        }
        return VCurrentUser.user( inManagedObjectContext: persistentStore.mainContext )
    }
    
    static func isLoggedIn() -> Bool {
        var isLoggedIn = false
        persistentStore.mainContext.performBlockAndWait() {
            isLoggedIn = VCurrentUser.user() != nil
        }
        return isLoggedIn
    }
    
    /// Strips the current user of its "current" status.  `currentUser()` method will
    /// now return nil until a new user has been set as current using method `setAsCurrent()`.
    static func clear() {
        persistentStore.mainContext.v_performBlockAndWait() { context in
            context.userInfo[ kManagedObjectContextUserInfoCurrentUserKey ] = nil
            NSNotificationCenter.defaultCenter().postNotificationName(kLoggedInChangedNotification, object: nil)
        }
    }
}

extension VUser {
    /// Sets the receiver as the current user returned in `currentUser()` method.  Any previous
    /// current user will lose its current status, as there can be only one.
    func setAsCurrentUser() {
        let persistentStore = VCurrentUser.persistentStore
        
        guard self.managedObjectContext == persistentStore.mainContext else {
            assertionFailure( "Attempt to set a user as the current user from a context other than the persistent store's main context. Make sure the receiver (a `VUser`) was loaded from the main context." )
            return
        }
        
        persistentStore.mainContext.v_performBlockAndWait() { context in
            context.userInfo[ kManagedObjectContextUserInfoCurrentUserKey ] = self
            NSNotificationCenter.defaultCenter().postNotificationName(kLoggedInChangedNotification, object: nil)
        }
    }
}
