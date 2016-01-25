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
    /// (for performance and conveninece reasons).  This method is thread safe, and will handle loading
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
            fatalError( "Attempt to read current user from the persistent store's main context from a thread other than the main thread.  Use method `user(inManagedObjectcontext:)` and provide the context in which you are working." )
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
        }
    }
}


/// Stores results of previous fetch requests to reduce the number of fetch requests that need be made
private let fetchedHashtagCache = NSCache()
private let fetchedUserCache = NSCache()

extension VUser {
    
    /// Sets the receiver as the current user returned in `currentUser()` method.  Any previous
    /// current user will lose its current status, as there can be only one.
    func setAsCurrentUser() {
        let persistentStore = VCurrentUser.persistentStore
        
        guard self.managedObjectContext == persistentStore.mainContext else {
            fatalError( "Attempt to set a user from a persistent store's main context as the current user.  Make sure the receiver (a `VUser`) was loaded from the main context." )
        }
        
        persistentStore.mainContext.v_performBlockAndWait() { context in
            context.userInfo[ kManagedObjectContextUserInfoCurrentUserKey ] = self
        }
    }
    
    func isCurrentUser() -> Bool {
        return self.isEqualToUser( VCurrentUser.user() )
    }
    
    func isCurrentUserFollowingHashtagString(hashtagString: String) -> Bool {
        guard isCurrentUser() else {
            fatalError( "This method is for the current user only" )
        }
        
        if let hashtag = fetchedHashtagCache.objectForKey(hashtagString) as? VHashtag
            where hashtag.tag == hashtagString  {
                return hashtag.isFollowedByMainUser
        }
        
        return PersistentStoreSelector.defaultPersistentStore.mainContext.v_performBlockAndWait() { context in
            if let hashtag: VHashtag = context.v_findObjects( [ "tag" : hashtagString] ).first {
                fetchedHashtagCache.setObject( hashtag, forKey: hashtagString)
                return hashtag.isFollowedByMainUser
            } else {
                return false
            }
        }
    }
    
    func isCurrentUserFollowingUserID( userID: Int ) -> Bool {
        guard isCurrentUser() else {
            fatalError( "This method is for the current user only" )
        }
        
        if let user = fetchedUserCache.objectForKey(userID) as? VUser
            where user.remoteId == userID  {
                return user.isFollowedByMainUser?.boolValue ?? false
        }
        
        return PersistentStoreSelector.defaultPersistentStore.mainContext.v_performBlockAndWait() { context in
            if let user: VUser = context.v_findObjects( [ "tag" : userID] ).first {
                fetchedUserCache.setObject( user, forKey: userID)
                return user.isFollowedByMainUser?.boolValue ?? false
            } else {
                return false
            }
        }
    }
}
