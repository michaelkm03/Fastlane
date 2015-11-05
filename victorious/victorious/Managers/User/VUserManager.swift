//
//  VUserManager.swift
//  victorious
//
//  Created by Josh Hinman on 10/27/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import CoreData
import FBSDKCoreKit
import Foundation
import VictoriousIOSSDK

private let kLastLoginTypeUserDefaultsKey = "com.getvictorious.VUserManager.LoginType"

/// NOTE: Eventually all of VUserManager will be re-written in Swift here. But for now, I'm starting with Facebook
extension VUserManager {
    
    /// Log in using the current Facebook session (make sure you use the Facebook SDK to establish a session before calling this)
    func loginViaFacebookWithStoredToken(onCompletion completionBlock: VUserManagerLoginCompletionBlock, onError errorBlock: VUserManagerLoginErrorBlock) -> VCancelable {
        
        let objectManager = VObjectManager.sharedManager()
        let facebookToken = FBSDKAccessToken.currentAccessToken().tokenString
        let accountCreateEndpoint = AccountCreateRequest(credentials: .Facebook(accessToken: facebookToken))
        let cancelable = objectManager.executeRequest(accountCreateEndpoint) { (result, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if let result = result {
                    if result.newUser {
                        VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserPermissionDidChange,
                                                                        parameters: [VTrackingKeyPermissionName: VTrackingValueAuthorized,
                                                                                     VTrackingKeyPermissionState: VTrackingValueFacebookDidAllow])
                        VTrackingManager.sharedInstance().trackEvent(VTrackingEventSignupWithFacebookDidSucceed)
                    }
                    VTrackingManager.sharedInstance().trackEvent(VTrackingEventLoginWithFacebookDidSucceed)
                    NSUserDefaults.standardUserDefaults().setInteger(VLoginType.FaceBook.rawValue, forKey: kLastLoginTypeUserDefaultsKey)
                    completionBlock(self.loggedIn(withUser: result.user, token: result.token, loginType: .FaceBook, objectManager: objectManager), result.newUser)
                } else {
                    errorBlock(error as? NSError, false)
                }
            }
        }
        return VCancelable(cancelable)
    }
    
    private func loggedIn(withUser user: User, token: String, loginType: VLoginType, objectManager: VObjectManager) -> VUser {
        // TODO: check for existing user
        let moc = objectManager.managedObjectStore.mainQueueManagedObjectContext
        let managedUser = VUser(entity: NSEntityDescription.entityForName(VUser.entityName(), inManagedObjectContext: moc)!, insertIntoManagedObjectContext: moc)
        managedUser.remoteId = NSNumber(longLong: user.userID)
        managedUser.email = user.email
        managedUser.name = user.name
        managedUser.status = user.status.rawValue
        managedUser.location = user.location
        managedUser.tagline = user.tagline
        managedUser.token = token
        
        do {
            try moc.saveToPersistentStore()
        } catch {
        }
        
        objectManager.mainUser = managedUser
        objectManager.loginType = loginType
        VStoredLogin().saveLoggedInUserToDisk(managedUser, loginType: loginType)
        
        objectManager.loadConversationListWithPageType(.First, successBlock: nil, failBlock: nil)
        NSNotificationCenter.defaultCenter().postNotificationName(kLoggedInChangedNotification, object: self)
        
        return managedUser
    }
}
