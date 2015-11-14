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
        return currentUser(inContext: PersistentStore.mainContext)
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
