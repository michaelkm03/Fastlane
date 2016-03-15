//
//  FollowedHashtagsOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 12/19/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class FollowedHashtagsOperation: FetcherOperation, PaginatedOperation {
    
    let paginator: StandardPaginator
    
    required init(paginator: StandardPaginator = StandardPaginator()) {
        self.paginator = paginator
        super.init()
        
        if !localFetch {
            let request = HashtagSubscribedToListRequest(paginator: paginator)
            FollowedHashtagsRemoteOperation(request: request).before(self).queue()
        }
    }
    
    required convenience init(operation: FollowedHashtagsOperation, paginator: StandardPaginator) {
        self.init(paginator: paginator)
    }
    
    override func main() {
        persistentStore.mainContext.v_performBlockAndWait() { context in
            guard let currentUser = VCurrentUser.user(inManagedObjectContext: context) else {
                self.results = []
                return
            }
            let fetchRequest = NSFetchRequest(entityName: VFollowedHashtag.v_entityName())
            fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "displayOrder", ascending: true) ]
            let predicate = NSPredicate(
                format: "user.remoteId == %@",
                argumentArray: [ currentUser.remoteId.integerValue ]
            )
            fetchRequest.predicate = predicate
            let fetchResults: [VFollowedHashtag] = context.v_executeFetchRequest( fetchRequest )
            self.results = fetchResults.map { $0.hashtag }
        }
    }
}
