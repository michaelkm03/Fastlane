//
//  UsersFollowedByUserOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 12/19/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class UsersFollowedByUser: RequestOperation, PaginatedOperation {
    
    let request: SubscribedToListRequest
    var resultCount: Int?
    
    private var userID: Int64
    
    private(set) var results: [AnyObject]?
    
    required init( request: SubscribedToListRequest ) {
        self.userID = request.userID
        self.request = request
    }
    
    convenience init( userID: Int64 ) {
        self.init( request: SubscribedToListRequest(userID: userID) )
    }
    
    override func main() {
        executeRequest( request, onComplete: self.onComplete, onError: self.onError )
    }
    
    private func onError( error: NSError, completion:(()->()) ) {
        if error.code == RequestOperation.errorCodeNoNetworkConnection {
            let results = loadPersistentData()
            self.results = results
            self.resultCount = results.count
            
        } else {
            self.resultCount = 0
        }
        completion()
    }
    
    private func onComplete( users: SubscribedToListRequest.ResultType, completion:()->() ) {
        
        persistentStore.backgroundContext.v_performBlock() { context in
            
            let follower: VUser = context.v_findOrCreateObject([ "remoteId" : NSNumber( longLong: self.userID ) ])
            
            for user in users {
                let uniqueElements = [ "remoteId" : NSNumber( longLong: user.userID ) ]
                let persistentUser: VUser = context.v_findOrCreateObject( uniqueElements )
                persistentUser.populate(fromSourceModel: user)
                persistentUser.v_addObject( follower, to: "followers" )
            }
            context.v_save()
            
            dispatch_async( dispatch_get_main_queue() ) {
                let results = self.loadPersistentData()
                self.results = results
                self.resultCount = results.count
                completion()
            }
        }
    }
    
    private func loadPersistentData() -> [VUser] {
        // TODO: Load users who are followed by main user
        return []
    }
}