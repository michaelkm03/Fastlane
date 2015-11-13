//
//  AccountCreateOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

// Extensions for Objective-C
/*class AccountCreateOperationObjc: NSObject {
    
    class func createWithEmail(email: String, password: String) -> NetworkOperation {
        let accountCreateRequest = AccountCreateRequest(credentials: .EmailPassword(email: email, password: password))
        return AccountCreateOperation( request: accountCreateRequest, loginType: .Email, accountIdentifier: email )
    }
    
    class func createWithFacebook() -> NetworkOperation {
        let loginType = VLoginType.Facebook
        let credentials: NewAccountCredentials = loginType.storedCredentials()!
        let accountCreateRequest = AccountCreateRequest(credentials: credentials)
        return AccountCreateOperation( request: accountCreateRequest, loginType: loginType )
    }
}*/

class AccountCreateOperation: RequestOperation<AccountCreateRequest> {
    
    private let loginType: VLoginType
    private let accountIdentifier: String?
    private var userObjectIdentifier: AnyObject?
    
    var isNewUser = false
    
    var persistentUser: VUser?
    
    init( request: AccountCreateRequest, loginType: VLoginType, accountIdentifier: String? = nil ) {
        self.loginType = loginType
        self.accountIdentifier = accountIdentifier
        super.init( request: request )
    }
    
    override func onResponse(result: AccountCreateResponse) {
        let dataStore = PersistentStore.backgroundContext
        let persistentUser: VUser = dataStore.findOrCreateObject( [ "remoteId" : Int(result.user.userID) ])
        persistentUser.populate(fromSourceModel: result.user)
        persistentUser.loginType = loginType.rawValue
        persistentUser.token = result.token
        persistentUser.setCurrentUser(inContext: dataStore)
        guard dataStore.saveChanges() else {
            fatalError( "Failed to create new user, something is wrong with the persistence stack!" )
        }
        
        isNewUser = result.newUser
        userObjectIdentifier = persistentUser.identifier
    }
    
    override func onError(error: NSError?) {
        loginType.trackFailure()
    }
    
    override func onComplete() {
        
        let dataStore = PersistentStore.mainContext
        guard self.finished,
            let identifier = userObjectIdentifier,
            let persistentUser: VUser = dataStore.getObject(identifier) else {
            fatalError( "Something's wrong." )
        }
        
        self.persistentUser = persistentUser
        
        // TODO: Check if userINfo cache transfers to main context from background
        
        NSUserDefaults.standardUserDefaults().setInteger( loginType.rawValue, forKey: kLastLoginTypeUserDefaultsKey)
        if let accountIdentifier = accountIdentifier {
            NSUserDefaults.standardUserDefaults().setObject( accountIdentifier, forKey: kAccountIdentifierDefaultsKey)
        }
        
        loginType.trackSuccess( isNewUser )
        
        self.queueNext( ConversationListOperation() )
        
        // TODO: (from object manager)
        /*
        [[VTrackingManager sharedInstance] setValue:@(YES) forSessionParameterWithKey:VTrackingKeyUserLoggedIn]
        
        [self loadConversationListWithPageType:VPageTypeFirst successBlock:nil failBlock:nil]
        [self pollResultsForUser:self.mainUser successBlock:nil failBlock:nil]
        
        // Add followers and following to main user object
        [[VObjectManager sharedManager] loadFollowersForUser:self.mainUser
        pageType:VPageTypeFirst
        successBlock:nil
        failBlock:nil]
        [[VObjectManager sharedManager] loadFollowingsForUser:self.mainUser
        pageType:VPageTypeFirst
        successBlock:nil
        failBlock:nil]
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kLoggedInChangedNotification object:self]*/
        
        VStoredLogin().saveLoggedInUserToDisk( persistentUser )
        NSNotificationCenter.defaultCenter().postNotificationName(kLoggedInChangedNotification, object: self)
    }
}

extension VLoginType {
    
    func trackSuccess(newUser: Bool) {
        switch self {
        case .Email:
            VTrackingManager.sharedInstance().trackEvent(VTrackingEventLoginWithEmailDidSucceed)
        case .Facebook:
            if newUser {
                let params = [
                    VTrackingKeyPermissionName: VTrackingValueAuthorized,
                    VTrackingKeyPermissionState: VTrackingValueFacebookDidAllow
                ]
                VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserPermissionDidChange, parameters: params)
                VTrackingManager.sharedInstance().trackEvent(VTrackingEventSignupWithFacebookDidSucceed)
            }
            VTrackingManager.sharedInstance().trackEvent(VTrackingEventLoginWithFacebookDidSucceed)
        case .Twitter:
            VTrackingManager.sharedInstance().trackEvent(VTrackingEventLoginWithTwitterDidSucceed)
        default:
            return
        }
    }
    
    func trackFailure() {
        switch self {
        case .Email:
            VTrackingManager.sharedInstance().trackEvent(VTrackingEventLoginWithEmailDidFail)
        case .Facebook:
            VTrackingManager.sharedInstance().trackEvent(VTrackingEventLoginWithFacebookDidFail)
        case .Twitter:
            VTrackingManager.sharedInstance().trackEvent(VTrackingEventLoginWithTwitterDidFailUnknown)
        default:
            return
        }
    }
}
