//
//  VUser+CurrentUserCache.swift
//  victorious
//
//  Created by Patrick Lynch on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import CoreData

let kLastLoginTypeUserDefaultsKey = "com.getvictorious.VUserManager.LoginType"
let kAccountIdentifierDefaultsKey = "com.getvictorious.VUserManager.AccountIdentifier"

extension VUser {
    
    private static var cacheKey: String {
        return "com.victorious.Persstence.CurrentUser"
    }
    
    /// Returns a `VUser` object from the context memory cache, which is more performant than
    /// a fetch request or relationship.  This method is thread safe, and will handle loading
    /// the user from the proper context depending on which thread it is invoked.
    static func currentUser() -> VUser? {
        
        let persistentStore: PersistentStoreType = MainPersistentStore()
        
        if NSThread.currentThread().isMainThread {
            return persistentStore.sync { context in
                context.cachedObjectForKey( VUser.cacheKey ) as? VUser
            }
        }
        else if let cachedUser = persistentStore.sync({ context in
            context.cachedObjectForKey( VUser.cacheKey ) as? VUser
        }) {
            return persistentStore.syncFromBackground { context in
                return context.getObject( cachedUser.identifier )
            }
        }
        return nil
    }
    
    static func clearCurrentUser( inContext context: PersistentStoreContextBasic ) {
        context.cacheObject( nil, forKey: VUser.cacheKey )
    }
    
    func setCurrentUser( inContext context: PersistentStoreContextBasic ) {
        context.cacheObject( self, forKey: VUser.cacheKey )
    }
    
    private static func currentUser( inContext context: PersistentStoreContextBasic ) -> VUser? {
        return context.cachedObjectForKey( VUser.cacheKey ) as? VUser
    }
}
