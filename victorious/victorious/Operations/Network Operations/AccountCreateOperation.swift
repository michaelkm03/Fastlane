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
    
    var isNewUser = false
    var persistentUser: VUser?
    
    init( request: AccountCreateRequest, loginType: VLoginType, accountIdentifier: String? = nil ) {
        self.loginType = loginType
        self.accountIdentifier = accountIdentifier
        super.init( request: request )
    }
    
    // MARK: - Operation overrides
    
    override func onResponse( response: AccountCreateRequest.ResultType ) {
        let dataStore = PersistentStore.backgroundContext
        let persistentUser: VUser = dataStore.findOrCreateObject( [ "remoteId" : Int(response.user.userID) ])
        persistentUser.populate(fromSourceModel: response.user)
        persistentUser.loginType = self.loginType.rawValue
        persistentUser.token = response.token
        persistentUser.setCurrentUser(inContext: dataStore)
        guard dataStore.saveChanges() else {
            fatalError( "Failed to create new user, something is wrong with the persistence stack!" )
        }
        
        // Set these to be accessed during completion on main thread
        self.userIdentifier = persistentUser.identifier
        self.isNewUser = response.newUser
    }
    
    override func onComplete( error: NSError? ) {
        let dataStore = PersistentStore.mainContext
        guard let identifier = userIdentifier,
            let persistentUser: VUser = dataStore.getObject(identifier) else {
                fatalError( "Failed to add create current user.  Check code in the `onResponse(_:) method." )
        }
        
        persistentUser.setCurrentUser(inContext: dataStore)
        VStoredLogin().saveLoggedInUserToDisk( persistentUser )
        self.persistentUser = persistentUser
        
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
