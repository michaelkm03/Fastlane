//
//  ContentFeedRemoteOperation.swift
//  victorious
//
//  Created by Vincent Ho on 5/17/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

final class ContentFeedRemoteOperation: RemoteFetcherOperation {
    private(set) var refreshStage: RefreshStage?
    
    // MARK: - Initializing
    
    init(request: ContentFeedRequest) {
        self.request = request
    }
    
    convenience init(url: NSURL) {
        self.init(request: ContentFeedRequest(url: url))
    }
    
    // MARK: - Executing
    
    let request: ContentFeedRequest
    
    override func main() {
        requestExecutor.executeRequest(request, onComplete: { [weak self] (contents, refreshStage) in
            self?.refreshStage = refreshStage
            self?.onComplete(contents)
        }, onError: nil)
    }
    
    func onComplete(contents: [Content]) {
        // Make changes on background queue
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            self.results = contents.flatMap { sdkContent in
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
