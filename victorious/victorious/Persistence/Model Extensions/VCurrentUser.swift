//
//  VCurrentUser.swift
//  victorious
//
//  Created by Patrick Lynch on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import CoreData

let kLastLoginTypeUserDefaultsKey = "com.getvictorious.VUserManager.LoginType"
let kAccountIdentifierDefaultsKey = "com.getvictorious.VUserManager.AccountIdentifier"

final class VCurrentUser: NSObject {
    private(set) static var user: User?
    static let userDidUpdateNotificationKey = "com.getvictorious.CurrentUser.DidUpdate"
    
    // Must be called on main queue
    static func update(to user: User) {
        assert(NSThread.isMainThread())
        
        let loggedInUserChanged = self.user == nil
        
        self.user = user
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: userDidUpdateNotificationKey, object: nil))
        if loggedInUserChanged {
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: kLoggedInChangedNotification, object: nil))
        }
    }
    
    static func clear() {
        user = nil
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: kLoggedInChangedNotification, object: nil))
    }
    
    static var loginType: VLoginType = .None
    static var token: String?
    static var isNewUser: NSNumber?
    static var accountIdentifier: String?
}

// Objc compatibility
extension VCurrentUser {
    static var userID: NSNumber? {
        return user?.id
    }
    
    static var maxVideoUploadDuration: NSNumber? {
        return user?.maxVideoUploadDuration
    }
    
    static var isCreator: NSNumber? {
        return user?.accessLevel.isCreator
    }
    
    static var isVIPSubScriber: NSNumber? {
        return user?.hasValidVIPSubscription
    }
    
    static var exists: NSNumber? {
        return user != nil
    }
    
    static var completedProfile: NSNumber? {
        return user?.completedProfile
    }
}
