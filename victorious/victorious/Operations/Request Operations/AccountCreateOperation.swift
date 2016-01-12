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
    
    var isNewUser = false
    
    init( request: AccountCreateRequest, loginType: VLoginType, accountIdentifier: String? = nil ) {
        self.loginType = loginType
        self.accountIdentifier = accountIdentifier
        self.request = request
    }
    
    // MARK: - Operation overrides
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: onComplete, onError: nil )
    }
    
    func onComplete( response: AccountCreateResponse, completion:()->() ) {
        self.isNewUser = response.newUser
        
        // First, find or create the new user who just logged in
        persistentStore.backgroundContext.v_performBlock() { context in
            let user: VUser = context.v_findOrCreateObject( [ "remoteId" : response.user.userID ])
            user.setAsCurrentUser()
            user.populate(fromSourceModel: response.user)
            user.loginType = self.loginType.rawValue
            user.token = response.token
            context.v_save()
            
            dispatch_async( dispatch_get_main_queue() ) {
                if let currentUser = VCurrentUser.user() {
                    self.updateStoredCredentials( currentUser )
                    self.notifyLoginChange( currentUser, isNewUser: response.newUser )
                    self.queueNextOperations( currentUser )
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
        PollResultSummaryByUserOperation( userID: currentUser.remoteId.integerValue ).queueAfter( self, queue: Operation.defaultQueue )
        ConversationListOperation().queueAfter( self, queue: Operation.defaultQueue )
        
        // TODO: Think of some other things we can load here just to get the objects into the persistence store
        // so that they are avilable offline.  Perhaps current user's liked sequences, profile stream, settings, user info fetches
        // for any others with whom a conversation is active.
    }
}
