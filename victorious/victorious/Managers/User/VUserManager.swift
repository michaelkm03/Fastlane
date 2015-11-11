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
            if let result = result {
                let user = self.getPersistentUser( fromSourceModel: result.user, token: result.token, loginType: .Email)
                dispatch_async(dispatch_get_main_queue()) {
                    if result.newUser {
                        VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserPermissionDidChange,
                                                                        parameters: [VTrackingKeyPermissionName: VTrackingValueAuthorized,
                                                                                     VTrackingKeyPermissionState: VTrackingValueFacebookDidAllow])
                        VTrackingManager.sharedInstance().trackEvent(VTrackingEventSignupWithFacebookDidSucceed)
                    }
                    VTrackingManager.sharedInstance().trackEvent(VTrackingEventLoginWithFacebookDidSucceed)
                    NSUserDefaults.standardUserDefaults().setInteger(VLoginType.FaceBook.rawValue, forKey: kLastLoginTypeUserDefaultsKey)
                    self.loginComplete( user )
                    completionBlock(user, result.newUser)
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
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
            if let result = result {
                let user = self.getPersistentUser( fromSourceModel: result.user, token: result.token, loginType: .Email)
                dispatch_async(dispatch_get_main_queue()) {
                    NSUserDefaults.standardUserDefaults().setInteger(VLoginType.Twitter.rawValue, forKey: kLastLoginTypeUserDefaultsKey)
                    NSUserDefaults.standardUserDefaults().setObject(twitterID, forKey: kAccountIdentifierDefaultsKey)
                    self.loginComplete( user )
                    completionBlock(user, result.newUser)
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
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
            if let result = result {
                let user = self.getPersistentUser( fromSourceModel: result.user, token: result.token, loginType: .Email)
                dispatch_async(dispatch_get_main_queue()) {
                    NSUserDefaults.standardUserDefaults().setInteger(VLoginType.Email.rawValue, forKey: kLastLoginTypeUserDefaultsKey)
                    NSUserDefaults.standardUserDefaults().setObject(email, forKey: kAccountIdentifierDefaultsKey)
                    VStoredPassword().savePassword(password, forEmail: email)
                    self.loginComplete( user )
                    completionBlock(user, result.newUser)
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    errorBlock(error as? NSError, false)
                }
            }
        }
    }
    
    /// Log in using an e-mail address and password
    func loginViaEmail(email: String, password: String, onCompletion completionBlock: VUserManagerLoginCompletionBlock, onError errorBlock: VUserManagerLoginErrorBlock) -> Cancelable {
        let objectManager = VObjectManager.sharedManager()
        let accountCreateRequest = AccountCreateRequest(credentials: .EmailPassword(email: email, password: password))
        
        // Execute with operations in stead of object manager, use shared operaiton queue for VUserManager
        
        return objectManager.executeRequest(accountCreateRequest) { (result, error) -> () in
            if let result = result {
                let user = self.getPersistentUser( fromSourceModel: result.user, token: result.token, loginType: .Email)
                dispatch_async(dispatch_get_main_queue()) {
                    NSUserDefaults.standardUserDefaults().setInteger(VLoginType.Email.rawValue, forKey: kLastLoginTypeUserDefaultsKey)
                    NSUserDefaults.standardUserDefaults().setObject(email, forKey: kAccountIdentifierDefaultsKey)
                    VStoredPassword().savePassword(password, forEmail: email)
                    self.loginComplete( user )
                    completionBlock(user, result.newUser)
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    errorBlock(error as? NSError, false)
                }
            }
        }
    }
    
    private func getPersistentUser( fromSourceModel user: User, token: String, loginType: VLoginType ) -> VUser {
        assert( NSThread.currentThread().isMainThread == false, "Must be on background thread." )
        
        let dataStore = PersistentStore.backgroundContext
        let persistentUser: VUser = dataStore.findOrCreateObject( [ "remoteId" : Int(user.userID) ])
        persistentUser.populate(fromSourceModel: user)
        persistentUser.loginType = loginType.rawValue
        persistentUser.token = token
        guard dataStore.saveChanges() else {
            fatalError( "Failed to create new user, something is wrong with the persistence stack!" )
        }
        return persistentUser
    }
    
    private func loginComplete(persistentUser: VUser) {
        
        // TODO: Remove these
        // objectManager.mainUser = persistentUser
        // objectManager.loginType = loginType
        
        // TODO: objectManager.loadConversationListWithPageType(.First, successBlock: nil, failBlock: nil)
        
        let loginType = VLoginType(rawValue:persistentUser.loginType.integerValue) ?? .None
        VStoredLogin().saveLoggedInUserToDisk(persistentUser, loginType: loginType )
        NSNotificationCenter.defaultCenter().postNotificationName(kLoggedInChangedNotification, object: self)
    }
}
