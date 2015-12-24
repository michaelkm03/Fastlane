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
    
    private(set) var results: [AnyObject]?
    private(set) var didResetResults: Bool = false
    
    required init( request: HashtagSubscribedToListRequest ) {
        self.request = request
    }
    
    convenience override init() {
        let paginator = StandardPaginator(pageNumber: 1, itemsPerPage: 200)
        self.init( request: HashtagSubscribedToListRequest( paginator: paginator ) )
    }
    
    convenience init( hashtagID: Int64 ) {
        self.init( request: HashtagSubscribedToListRequest() )
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
    
    func onComplete( hashtags: HashtagSubscribedToListRequest.ResultType, completion:()->() ) {
        guard let currentUser = VUser.currentUser() else {
            completion()
            return
        }
        
        var displayOrder = (self.request.paginator.pageNumber - 1) * self.request.paginator.itemsPerPage
        
        var hashtagObjectIDs = [NSManagedObjectID]()
        persistentStore.backgroundContext.v_performBlock() { context in
            for hashtag in hashtags {
                let hashtag: VHashtag = context.v_findOrCreateObject( [ "remoteId" : NSNumber( longLong: hashtag.hashtagID ) ] )
                hashtagObjectIDs.append( hashtag.objectID )
                
                let followedHashtag: VFollowedHashtag = context.v_findOrCreateObject( [ "user" : currentUser ] )
                followedHashtag.userId = currentUser.remoteId
                followedHashtag.displayOrder = displayOrder++
                currentUser.v_addObject( followedHashtag, to: "hashtags" )
            }
            context.v_save()
            
            self.results = self.fetchResults()
            completion()
        }
    }
    
    func fetchResults() -> [VFollowedHashtag] {
        guard let currentUser = VUser.currentUser() else {
            return []
        }
        
        return persistentStore.mainContext.v_performBlockAndWait() { context in
            let fetchRequest = NSFetchRequest(entityName: VFollowedHashtag.v_entityName())
            fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "displayOrder", ascending: true) ]
            let predicate = NSPredicate(
                format: "userId = %@",
                argumentArray: [ currentUser.remoteId ],
                paginator: self.request.paginator
            )
            fetchRequest.predicate = predicate
            return context.v_executeFetchRequest( fetchRequest )
        }
    }
}
