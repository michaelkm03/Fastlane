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
    var resultCount: Int?
    
    private(set) var loadedHashtags = [VHashtag]()
    
    required init( request: HashtagSubscribedToListRequest ) {
        self.request = request
    }
    
    convenience init( hashtagID: Int64 ) {
        self.init( request: HashtagSubscribedToListRequest() )
    }
    
    override func main() {
        executeRequest( request, onComplete: self.onComplete, onError: self.onError )
    }
    
    private func onError( error: NSError, completion:(()->()) ) {
        self.resultCount = 0
        completion()
    }
    
    private func onComplete( hashtags: HashtagSubscribedToListRequest.ResultType, completion:()->() ) {
        self.resultCount = hashtags.count
        
        var hashtagObjectIDs = [NSManagedObjectID]()
        
        persistentStore.backgroundContext.v_performBlock() { context in
            for hashtag in hashtags {
                let uniqueElements = [ "remoteId" : NSNumber( longLong: hashtag.hashtagID ) ]
                let hashtag: VHashtag = context.v_findOrCreateObject( uniqueElements )
                hashtagObjectIDs.append( hashtag.objectID )
            }
            context.v_save()
            
            self.persistentStore.mainContext.v_performBlock() { context in
                var hashtags = [VHashtag]()
                for objectID in hashtagObjectIDs {
                    if let hashtag = context.objectWithID( objectID ) as? VHashtag {
                        hashtags.append( hashtag )
                    }
                }
                self.loadedHashtags = hashtags
                completion()
            }
        }
    }
}
