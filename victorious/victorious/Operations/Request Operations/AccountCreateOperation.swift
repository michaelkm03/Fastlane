//
//  AccountCreateOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class AccountCreateOperation: RequestOperation {
    
    private let loginType: VLoginType
    private let accountIdentifier: String?
    
    var currentRequest: AccountCreateRequest
    
    var isNewUser = false
    var persistentUser: VUser?
    
    init( request: AccountCreateRequest, loginType: VLoginType, accountIdentifier: String? = nil ) {
        self.loginType = loginType
        self.accountIdentifier = accountIdentifier
        self.currentRequest = request
    }
    
    // MARK: - Operation overrides
    
    override func main() {
        executeRequest( currentRequest, onComplete: self.onComplete )
    }
    
    private func onComplete( response: AccountCreateResponse, completion:()->() ) {
        self.isNewUser = response.newUser
        
        // First, find or create the new user who just logged in
        persistentStore.asyncFromBackground() { context in
            let user: VUser = context.findOrCreateObject( [ "remoteId" : NSNumber( longLong: response.user.userID) ])
            user.populate(fromSourceModel: response.user)
            user.loginType = self.loginType.rawValue
            user.token = response.token
            context.saveChanges()
            
            let identifier = user.identifier
            dispatch_async( dispatch_get_main_queue() ) {
                let currentUser = self.setCurrentUser( identifier )!
                self.updateStoredCredentials( currentUser )
                self.notifyLoginChange( currentUser, isNewUser: response.newUser )
                self.queueNextOperations( currentUser )
                completion()
            }
        }
    }
    
    private func setCurrentUser( identifier: AnyObject ) -> VUser? {
        return self.persistentStore.sync() { context in
            if let persistentUser: VUser = context.getObject(identifier) {
                persistentUser.setAsCurrentUser(inContext: context)
                return persistentUser
            }
            return nil
        }
    }
    
    private func updateStoredCredentials( user: VUser ) {
        VStoredLogin().saveLoggedInUserToDisk( user )
        NSUserDefaults.standardUserDefaults().setInteger( user.loginType.integerValue, forKey: kLastLoginTypeUserDefaultsKey)
        if let accountIdentifier = self.accountIdentifier {
            NSUserDefaults.standardUserDefaults().setObject( accountIdentifier, forKey: kAccountIdentifierDefaultsKey)
        }
    }
    
    private func notifyLoginChange( user: VUser, isNewUser: Bool ) {
        VLoginType(rawValue: user.loginType.integerValue )?.trackSuccess( isNewUser )
        NSNotificationCenter.defaultCenter().postNotificationName(kLoggedInChangedNotification, object: nil)
    }
    
    private func queueNextOperations( currentUser: VUser ) {
        // Load more data from the network about the user
        PollResultByUserOperation( userID: currentUser.remoteId.longLongValue ).queueAfter( self, queue: Operation.defaultQueue )
        ConversationListOperation().queueAfter( self, queue: Operation.defaultQueue )
    }
}
