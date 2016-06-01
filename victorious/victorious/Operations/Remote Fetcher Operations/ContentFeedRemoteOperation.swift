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
            self.results = sourceFeed.flatMap { sdkContent in
                guard let id = sdkContent.id else {
                    return nil
                }
                
                let content: VContent = context.v_findOrCreateObject(["v_remoteID": id])
                content.populate(fromSourceModel: sdkContent)
                return content.id
            }
            
            context.v_save()
        }
    }
}
