//
//  FollowedHashtagsOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 12/19/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class FollowedHashtagsOperation: RequestOperation, PaginatedOperation {
    
    let request: HashtagSubscribedToListRequest
    
    required init( request: HashtagSubscribedToListRequest ) {
        self.request = request
    }
    
    convenience override init() {
        let paginator = StandardPaginator(pageNumber: 1, itemsPerPage: 100)
        self.init( request: HashtagSubscribedToListRequest( paginator: paginator ) )
    }
    
    convenience init( hashtagID: Int ) {
        self.init( request: HashtagSubscribedToListRequest() )
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: onComplete, onError: onError )
    }
    
    func onError( error: NSError, completion:(()->()) ) {
        if error.code == RequestOperation.errorCodeNoNetworkConnection {
            self.results = fetchResults()
            
        } else {
            self.results = []
        }
        completion()
    }
    
    func onComplete( hashtags: HashtagSubscribedToListRequest.ResultType, completion:()->() ) {
        
        storedBackgroundContext = persistentStore.createBackgroundContext().v_performBlock() { context in
            guard let currentUser = VCurrentUser.user(inManagedObjectContext: context) else {
                completion()
                return
            }
            
            var displayOrder = self.paginatedRequestExecutor.startingDisplayOrder
            
            for hashtag in hashtags {
                let persistentHashtag: VHashtag = context.v_findOrCreateObject( [ "tag" : hashtag.tag ] )
                persistentHashtag.populate(fromSourceModel: hashtag)
                
                let followedHashtag: VFollowedHashtag = context.v_findOrCreateObject( [ "user" : currentUser ] )
                followedHashtag.user = currentUser
                followedHashtag.hashtag = persistentHashtag
                followedHashtag.displayOrder = displayOrder++
            }
            context.v_save()
            
            self.results = self.fetchResults()
            completion()
        }
    }
    
    override func fetchResults() -> [AnyObject] {
        return persistentStore.mainContext.v_performBlockAndWait() { context in
            guard let currentUser = VCurrentUser.user(inManagedObjectContext: context) else {
                return []
            }
            let fetchRequest = NSFetchRequest(entityName: VFollowedHashtag.v_entityName())
            fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "displayOrder", ascending: true) ]
            let predicate = NSPredicate(
                v_format: "user.remoteId = %@",
                v_argumentArray: [ currentUser.remoteId ],
                v_paginator: self.request.paginator
            )
            fetchRequest.predicate = predicate
            let results: [VFollowedHashtag] = context.v_executeFetchRequest( fetchRequest )
            return results.flatMap { $0.hashtag }
        }
    }
}
