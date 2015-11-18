//
//  AccountCreateOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class AccountCreateOperation: RequestOperation<AccountCreateRequest> {
    
    private let loginType: VLoginType
    private let accountIdentifier: String?
    private var userIdentifier: AnyObject?
    private let persistentStore = PersistentStore()
    
    var isNewUser = false
    var persistentUser: VUser?
    
    init( request: AccountCreateRequest, loginType: VLoginType, accountIdentifier: String? = nil ) {
        self.loginType = loginType
        self.accountIdentifier = accountIdentifier
        super.init( request: request )
    }
    
    // MARK: - Operation overrides
    
    override func onResponse( response: AccountCreateRequest.ResultType ) {
        
        // Do this on the main thread so that changes are available immeidately in the `onComplete` method
        let persistentUser: VUser = persistentStore.sync() { context in
            let user: VUser = context.findOrCreateObject( [ "remoteId" : Int(response.user.userID) ])
            user.populate(fromSourceModel: response.user)
            user.loginType = self.loginType.rawValue
            user.token = response.token
            user.setCurrentUser(inContext: context)
            context.saveChanges()
            return user
        }
        
        dispatch_sync( dispatch_get_main_queue() ) {
            self.userIdentifier = persistentUser.identifier
            self.isNewUser = response.newUser
        }
    }
    
    override func onComplete( error: NSError? ) {
        
        // The the current user in our cache
        persistentStore.sync() { context in
            guard let identifier = self.userIdentifier, let persistentUser: VUser = context.getObject(identifier) else {
                fatalError( "Failed to add create current user.  Check code in the `onResponse(_:) method." )
            }
            persistentUser.setCurrentUser(inContext: context)
            VStoredLogin().saveLoggedInUserToDisk( persistentUser )
            self.persistentUser = persistentUser
        }
        
        NSUserDefaults.standardUserDefaults().setInteger( loginType.rawValue, forKey: kLastLoginTypeUserDefaultsKey)
        if let accountIdentifier = accountIdentifier {
            NSUserDefaults.standardUserDefaults().setObject( accountIdentifier, forKey: kAccountIdentifierDefaultsKey)
        }
        
        loginType.trackSuccess( isNewUser )
        
        NSNotificationCenter.defaultCenter().postNotificationName(kLoggedInChangedNotification, object: nil)
        
        // TODO: (from object manager)
        // [self pollResultsForUser:self.mainUser successBlock:nil failBlock:nil]
        
        self.queueNext( ConversationListOperation(), queue: Operation.defaultQueue )
    }
}
