//
//  ViewedContentStreamOperation.swift
//  victorious
//
//  Created by Vincent Ho on 5/17/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class ViewedContentFeedOperation: FetcherOperation, PaginatedOperation {
    
    let paginator: StreamPaginator
    var viewedContentIDs: [NSManagedObjectID]?
    
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
            ViewedContentFeedRemoteOperation(request: request).before(self).queue(){ [weak self] results, error, completed in
                self?.viewedContentIDs = results as? [NSManagedObjectID]
            }
        }
    }
    
    required convenience init(operation: ViewedContentFeedOperation, paginator: StreamPaginator) {
        self.init(paginator: paginator)
    }
    
    convenience init( apiPath: String, sequenceID: String? = nil) {
        self.init( paginator: StreamPaginator(apiPath: apiPath, sequenceID: sequenceID)!)
    }
    
    override func main() {
        persistentStore.mainContext.v_performBlockAndWait() { context in
            self.results = self.viewedContentIDs?.flatMap({
                return context.objectWithID($0)
            })
        }
    }
}
