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

public extension VUser {
    
    private static var cacheKey: String {
        return "com.victorious.Persstence.CurrentUser"
    }
    
    public static func currentUser() -> VUser? {
        let persistentStore = PersistentStore()
        
        if NSThread.currentThread().isMainThread {
            return persistentStore.sync { VUser.currentUser( inContext: $0 ) }
        }
        else if let cachedUser = persistentStore.sync({ VUser.currentUser( inContext: $0 ) }) {
            return persistentStore.syncFromBackground { context in
                return context.getObject( cachedUser.identifier )
            }
        }
        return nil
    }
    
    public static func currentUser( inContext context: DataStoreBasic ) -> VUser? {
        return context.cachedObjectForKey( VUser.cacheKey ) as? VUser
    }
    
    public static func clearCurrentUser( inContext context: DataStoreBasic ) {
        context.cacheObject( nil, forKey: VUser.cacheKey )
    }
    
    public func setCurrentUser( inContext context: DataStoreBasic ) {
        context.cacheObject( self, forKey: VUser.cacheKey )
    }
}
