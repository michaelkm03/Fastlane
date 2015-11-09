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
private let kAccountIdentifierDefaultsKey = "com.getvictorious.VUserManager.AccountIdentifier"

extension VUserManager {
    
    /// Log in using the current Facebook session (make sure you use the Facebook SDK to establish a session before calling this)
    func loginViaFacebookWithStoredToken(onCompletion completionBlock: VUserManagerLoginCompletionBlock, onError errorBlock: VUserManagerLoginErrorBlock) -> Cancelable {
        
        let objectManager = VObjectManager.sharedManager()
        let facebookToken = FBSDKAccessToken.currentAccessToken().tokenString
        let accountCreateRequest = AccountCreateRequest(credentials: .Facebook(accessToken: facebookToken))
        return objectManager.executeRequest(accountCreateRequest) { (result, error) in
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
                    completionBlock(self.loggedInWithUser(result.user, token: result.token, loginType: .FaceBook, objectManager: objectManager), result.newUser)
                } else {
                    errorBlock(error as? NSError, false)
                }
            }
        }
    }
    
    /// Log in using Twitter oauth data.
    func loginViaTwitterWithToken(oauthToken: String, accessSecret: String, twitterID: String, identifier: String, onCompletion completionBlock: VUserManagerLoginCompletionBlock, onError errorBlock: VUserManagerLoginErrorBlock) -> Cancelable {
        
        let objectManager = VObjectManager.sharedManager()
        let accountCreateRequest = AccountCreateRequest(credentials: .Twitter(accessToken: oauthToken, accessSecret: accessSecret, twitterID: twitterID))
        return objectManager.executeRequest(accountCreateRequest) { (result, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if let result = result {
                    NSUserDefaults.standardUserDefaults().setInteger(VLoginType.Twitter.rawValue, forKey: kLastLoginTypeUserDefaultsKey)
                    NSUserDefaults.standardUserDefaults().setObject(twitterID, forKey: kAccountIdentifierDefaultsKey)
                    completionBlock(self.loggedInWithUser(result.user, token: result.token, loginType: .Twitter, objectManager: objectManager), result.newUser)
                } else {
                    errorBlock(error as? NSError, false)
                }
            }
        }
    }
    
    /// Create a new account with the specified e-mail and password.
    /// If an account already exists on the server with the specified e-mail address
    /// an error will occur, unless the specified password matches the password on
    /// that account. In that case, the existing account will be logged in.
    func createAccountWithEmail(email: String, password: String, onCompletion completionBlock: VUserManagerLoginCompletionBlock, onError errorBlock: VUserManagerLoginErrorBlock) -> Cancelable {
        let objectManager = VObjectManager.sharedManager()
        let accountCreateRequest = AccountCreateRequest(credentials: .EmailPassword(email: email, password: password))
        return objectManager.executeRequest(accountCreateRequest) { (result, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if let result = result {
                    NSUserDefaults.standardUserDefaults().setInteger(VLoginType.Email.rawValue, forKey: kLastLoginTypeUserDefaultsKey)
                    NSUserDefaults.standardUserDefaults().setObject(email, forKey: kAccountIdentifierDefaultsKey)
                    VStoredPassword().savePassword(password, forEmail: email)
                    completionBlock(self.loggedInWithUser(result.user, token: result.token, loginType: .Email, objectManager: objectManager), result.newUser)
                } else {
                    errorBlock(error as? NSError, false)
                }
            }
        }
    }
    
    /// Log in using an e-mail address and password
    func loginViaEmail(email: String, password: String, onCompletion completionBlock: VUserManagerLoginCompletionBlock, onError errorBlock: VUserManagerLoginErrorBlock) -> Cancelable {
        let objectManager = VObjectManager.sharedManager()
        let accountCreateRequest = AccountCreateRequest(credentials: .EmailPassword(email: email, password: password))
        return objectManager.executeRequest(accountCreateRequest) { (result, error) -> () in
            dispatch_async(dispatch_get_main_queue()) {
                if let result = result {
                    NSUserDefaults.standardUserDefaults().setInteger(VLoginType.Email.rawValue, forKey: kLastLoginTypeUserDefaultsKey)
                    NSUserDefaults.standardUserDefaults().setObject(email, forKey: kAccountIdentifierDefaultsKey)
                    VStoredPassword().savePassword(password, forEmail: email)
                    completionBlock(self.loggedInWithUser(result.user, token: result.token, loginType: .Email, objectManager: objectManager), true)
                } else {
                    errorBlock(error as? NSError, false)
                }
            }
        }
    }
    
    private func loggedInWithUser(user: User, token: String, loginType: VLoginType, objectManager: VObjectManager) -> VUser {
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
