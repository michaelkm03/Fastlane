//
//  ContentFeedRemoteOperation.swift
//  victorious
//
//  Created by Vincent Ho on 5/17/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

final class ContentFeedRemoteOperation: RemoteFetcherOperation, PaginatedRequestOperation {
    
    let request: ContentFeedRequest
    
    required init( request: ContentFeedRequest ) {
        self.request = request
    }
    
    convenience init( apiPath: String, sequenceID: String? = nil) {
        self.init(request: ContentFeedRequest(apiPath: apiPath))
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: self.onComplete, onError: nil )
    }
    
    func onComplete(sourceFeed: ContentFeedRequest.ResultType) {
        
        // Make changes on background queue
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in            
            self.results = sourceFeed.flatMap({
                guard let id = $0.id else {
                    return nil
                }
                
                let content: VContent = context.v_findOrCreateObject(["remoteID": id])
                content.populate(fromSourceModel: $0)
                return content.remoteID
            })
            context.v_save()
        }
    }
}
