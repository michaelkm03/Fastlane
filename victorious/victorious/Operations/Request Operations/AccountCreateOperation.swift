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
    
    let request: AccountCreateRequest
    private(set) var resultCount: Int?
    
    var isNewUser = false
    var persistentUser: VUser?
    
    init( request: AccountCreateRequest, loginType: VLoginType, accountIdentifier: String? = nil ) {
        self.loginType = loginType
        self.accountIdentifier = accountIdentifier
        self.request = request
    }
    
    // MARK: - Operation overrides
    
    override func main() {
        executeRequest( request, onComplete: self.onComplete )
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
            self.persistentStore.sync() { context in
                if let user: VUser = context.getObject(identifier) {
                    user.setAsCurrentUser()
                    self.updateStoredCredentials( user )
                    self.notifyLoginChange( user, isNewUser: response.newUser )
                    self.queueNextOperations( user )
                }
                completion()
            }
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
