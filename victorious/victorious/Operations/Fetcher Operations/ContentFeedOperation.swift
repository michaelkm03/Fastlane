//
//  ContentFeedOperation.swift
//  victorious
//
//  Created by Vincent Ho on 5/17/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class ContentFeedOperation: FetcherOperation, PaginatedOperation {
    
    let paginator: StreamPaginator
    var contentIDs: [NSManagedObjectID]?
    
    required init(paginator: StreamPaginator) {
        self.paginator = paginator
        super.init()
        
        self.queuePriority = .VeryHigh
        
        if !localFetch {
            let request = ViewedContentFeedRequest(
                apiPath: paginator.apiPath,
                sequenceID: paginator.sequenceID,
                paginator: paginator
            )
            ContentFeedRemoteOperation(request: request).before(self).queue(){ [weak self] results, error, completed in
                self?.contentIDs = results as? [NSManagedObjectID]
            }
        }
    }
    
    required convenience init(operation: ContentFeedOperation, paginator: StreamPaginator) {
        self.init(paginator: paginator)
    }
    
    convenience init( apiPath: String) {
        self.init( paginator: StreamPaginator(apiPath: apiPath)!)
    }
    
    override func main() {
        persistentStore.mainContext.v_performBlockAndWait() { context in
            self.results = self.contentIDs?.flatMap({
                return context.objectWithID($0)
            })
        }
    }
}
