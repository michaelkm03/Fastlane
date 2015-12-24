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
    
    private var userID: Int64
    
    private(set) var results: [AnyObject]?
    private(set) var didResetResults: Bool = false
    
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
    
    func onError( error: NSError, completion:(()->()) ) {
        if error.code == RequestOperation.errorCodeNoNetworkConnection {
            self.results = fetchResults()
            
        } else {
            self.results = []
        }
        completion()
    }
    
    func onComplete( users: SubscribedToListRequest.ResultType, completion:()->() ) {
        
        persistentStore.backgroundContext.v_performBlock() { context in
            var displayOrder = (self.request.paginator.pageNumber - 1) * self.request.paginator.itemsPerPage
            
            let subjectUser: VUser = context.v_findOrCreateObject([ "remoteId" : NSNumber(longLong: self.userID) ])
            for user in users {
                let objectUser: VUser = context.v_findOrCreateObject( ["remoteId" : NSNumber(longLong: user.userID)] )
                objectUser.populate(fromSourceModel: user)
                
                let uniqueElements = [ "subjectUser" : subjectUser, "objectUser" : objectUser ]
                let followedUser: VFollowedUser = context.v_findOrCreateObject( uniqueElements )
                followedUser.objectUserId = NSNumber(longLong: self.userID)
                followedUser.displayOrder = displayOrder++
                
                subjectUser.v_addObject( followedUser, to: "followers" )
            }
            context.v_save()
            
            self.results = self.fetchResults()
            completion()
        }
    }
    
    func fetchResults() -> [VFollowedUser] {
        return persistentStore.mainContext.v_performBlockAndWait() { context in
            let fetchRequest = NSFetchRequest(entityName: VFollowedUser.v_entityName())
            fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "displayOrder", ascending: true) ]
            let predicate = NSPredicate(
                format: "objectUserId = %@",
                argumentArray: [ NSNumber(longLong: self.userID) ],
                paginator: self.request.paginator
            )
            fetchRequest.predicate = predicate
            return context.v_executeFetchRequest( fetchRequest )
        }
    }
}
