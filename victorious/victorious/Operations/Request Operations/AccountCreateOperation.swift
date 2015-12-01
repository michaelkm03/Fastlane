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
    
    private let persistentStore: PersistentStoreType = MainPersistentStore()
    
    private let loginType: VLoginType
    private let accountIdentifier: String?
    
    var isNewUser = false
    var persistentUser: VUser?
    
    init( request: AccountCreateRequest, loginType: VLoginType, accountIdentifier: String? = nil ) {
        self.loginType = loginType
        self.accountIdentifier = accountIdentifier
        super.init( request: request )
    }
    
    // MARK: - Operation overrides
    
    override func onComplete( response: AccountCreateRequest.ResultType, completion:()->() ) {
        self.isNewUser = response.newUser
        
        persistentStore.asyncFromBackground() { context in
            let user: VUser = context.findOrCreateObject( [ "remoteId" : NSNumber( longLong: response.user.userID) ])
            user.populate(fromSourceModel: response.user)
            user.loginType = self.loginType.rawValue
            user.token = response.token
            context.saveChanges()
            
            let identifier = user.identifier
            dispatch_async( dispatch_get_main_queue() ) {
                self.persistentStore.sync() { context in
                    guard let persistentUser: VUser = context.getObject(identifier) else {
                        fatalError( "Failed to add create current user.  Check code in the `onResponse(_:) method." )
                    }
                    persistentUser.setAsCurrentUser(inContext: context)
                    
                    VStoredLogin().saveLoggedInUserToDisk( persistentUser )
                    NSUserDefaults.standardUserDefaults().setInteger( persistentUser.loginType.integerValue, forKey: kLastLoginTypeUserDefaultsKey)
                    if let accountIdentifier = self.accountIdentifier {
                        NSUserDefaults.standardUserDefaults().setObject( accountIdentifier, forKey: kAccountIdentifierDefaultsKey)
                    }
                    
                    // Respond to the login
                    VLoginType(rawValue: persistentUser.loginType.integerValue )?.trackSuccess( response.newUser )
                    NSNotificationCenter.defaultCenter().postNotificationName(kLoggedInChangedNotification, object: nil)
                    
                    // Load more data from the network about the user
                    PollResultByUserOperation( userID: persistentUser.remoteId.longLongValue ).queueAfter( self, queue: Operation.defaultQueue )
                    ConversationListOperation().queueAfter( self, queue: Operation.defaultQueue )
                    
                    completion()
                }
            }
        }
    }
}

class PollResultByUserOperation: RequestOperation<PollResultByUserRequest> {
    
    private let persistentStore: PersistentStoreType = MainPersistentStore()
    private let userID: Int64
    
    init( userID: Int64 ) {
        self.userID = userID
        super.init( request: PollResultByUserRequest(userID: userID) )
    }
    
    override func onError(error: NSError, completion: () -> ()) {
        completion()
    }
    
    override func onComplete( response: PollResultByUserRequest.ResultType, completion:()->() ) {
        
        persistentStore.asyncFromBackground() { context in
            let pollResults: [VPollResult] = response.flatMap {
                let uniqueElements = [
                    "answerId" : NSNumber(longLong: $0.answerID),
                    "sequenceId" : String($0.sequenceID)
                ]
                let persistentResult: VPollResult = context.findOrCreateObject( uniqueElements )
                persistentResult.populate(fromSourceModel: $0)
                return persistentResult
            }
            guard let user: VUser = context.findObjects( [ "remoteId" :  NSNumber(longLong: self.userID) ] ).first else {
                fatalError( "Could not load user with provided user ID" )
            }
            user.addObjects( pollResults, to: "pollResults" )
            context.saveChanges()
            completion()
        }
    }
}
