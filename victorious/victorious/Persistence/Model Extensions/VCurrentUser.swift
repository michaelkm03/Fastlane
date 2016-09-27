//
//  VCurrentUser.swift
//  victorious
//
//  Created by Patrick Lynch on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

let kLastLoginTypeUserDefaultsKey = "com.getvictorious.VUserManager.LoginType"
let kAccountIdentifierDefaultsKey = "com.getvictorious.VUserManager.AccountIdentifier"

final class VCurrentUser: NSObject {
    fileprivate(set) static var user: User?
    static let userDidUpdateNotificationKey = "com.getvictorious.CurrentUser.DidUpdate"
    
    /// updates current user to the passed in user parameter.
    /// Will trigger `userDidUpdateNotificationKey` and `kLoggedInChangedNotification` notifications appropriately.
    /// - note: Must be called on the main thread because it modifies the user
    static func update(to user: User) {
        assert(Thread.isMainThread)
        
        let loggedInUserChanged = self.user == nil
        
        self.user = user
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: userDidUpdateNotificationKey), object: nil))
        if loggedInUserChanged {
            NotificationCenter.defaultCenter().postNotification(Notification(name: kLoggedInChangedNotification, object: nil))
        }
    }
    
    /// Clears current user. 
    /// - note: Must be called on the main queue because it modifies the user
    static func clear() {
        assert(Thread.isMainThread)
        user = nil
        NotificationCenter.defaultCenter().postNotification(Notification(name: kLoggedInChangedNotification, object: nil))
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
