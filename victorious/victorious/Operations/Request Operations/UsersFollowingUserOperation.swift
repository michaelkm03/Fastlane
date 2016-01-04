//
//  FollowersListOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 12/19/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class UsersFollowingUserOperation: RequestOperation, PaginatedOperation {
    
    let request: FollowersListRequest
    
    private var userID: Int64
    
    private(set) var results: [AnyObject]?
    private(set) var didResetResults: Bool = false
    
    required init( request: FollowersListRequest ) {
        self.userID = request.userID
        self.request = request
    }
    
    convenience init( userID: Int64 ) {
        self.init( request: FollowersListRequest(userID: userID) )
    }
    
    override func main() {
        executeRequest( request, onComplete: self.onComplete, onError: self.onError )
    }
    
    private func onError( error: NSError, completion:(()->()) ) {
        if error.code == RequestOperation.errorCodeNoNetworkConnection {
            self.results = fetchResults()
        } else {
            self.results = []
        }
        completion()
    }
    
    private func onComplete( results: SequenceLikersRequest.ResultType, completion:()->() ) {
        
        persistentStore.backgroundContext.v_performBlock() { context in
            var displayOrder = (self.request.paginator.pageNumber - 1) * self.request.paginator.itemsPerPage
            
            let objectUserId =  NSNumber(longLong: self.userID)
            let objectUser: VUser = context.v_findOrCreateObject([ "remoteId" : objectUserId ])
            
            for user in results {
                
                // Load the user who is following self.userID
                let subjectUserId = NSNumber(longLong: user.userID)
                let subjectUser: VUser = context.v_findOrCreateObject( ["remoteId" : subjectUserId] )
                subjectUser.populate(fromSourceModel: user)

                // Find or create the following relationship
                let uniqueElements = [ "subjectUser" : subjectUser, "objectUser" : objectUser ]
                let followedUser: VFollowedUser = context.v_findOrCreateObject( uniqueElements )
                followedUser.objectUser = objectUser
                followedUser.subjectUser = subjectUser
                followedUser.displayOrder = displayOrder++
            }
            context.v_save()
            
            self.results =  self.fetchResults()
            completion()
        }
    }
    
    private func fetchResults() -> [VUser] {
        return persistentStore.mainContext.v_performBlockAndWait() { context in
            let fetchRequest = NSFetchRequest(entityName: VFollowedUser.v_entityName())
            fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "displayOrder", ascending: true) ]
            let predicate = NSPredicate(
                v_format: "objectUser.remoteId = %@",
                v_argumentArray: [ NSNumber(longLong: self.userID) ],
                v_paginator: self.request.paginator
            )
            fetchRequest.predicate = predicate
            let results: [VFollowedUser] = context.v_executeFetchRequest( fetchRequest )
            return results.flatMap { $0.subjectUser }
        }
    }
}
