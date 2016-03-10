//
//  FollowedHashtagsRemoteOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

final class FollowedHashtagsRemoteOperation: RemoteFetcherOperation, PaginatedRequestOperation {
    
    let request: HashtagSubscribedToListRequest
    
    required init( request: HashtagSubscribedToListRequest ) {
        self.request = request
    }
    
    convenience init(paginator: StandardPaginator = StandardPaginator(pageNumber: 1, itemsPerPage: 30)) {
        self.init( request: HashtagSubscribedToListRequest( paginator: paginator ) )
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: onComplete, onError: nil )
    }
    
    func onComplete( hashtags: HashtagSubscribedToListRequest.ResultType) {
        
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            guard let currentUser = VCurrentUser.user(inManagedObjectContext: context) else {
                return
            }
            
            var displayOrder = self.request.paginator.displayOrderCounterStart
            for hashtag in hashtags {
                let persistentHashtag: VHashtag = context.v_findOrCreateObject( [ "tag" : hashtag.tag ] )
                persistentHashtag.populate(fromSourceModel: hashtag)
                
                let uniqueInfo = [ "user" : currentUser, "hashtag" : persistentHashtag ]
                let followedHashtag: VFollowedHashtag = context.v_findOrCreateObject( uniqueInfo )
                followedHashtag.user = currentUser
                followedHashtag.hashtag = persistentHashtag
                followedHashtag.displayOrder = displayOrder++
            }
            context.v_save()
        }
    }
}
