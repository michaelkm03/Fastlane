//
//  ContentFeedRemoteOperation.swift
//  victorious
//
//  Created by Vincent Ho on 5/17/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

final class ContentFeedRemoteOperation: RemoteFetcherOperation {
    
    // MARK: - Initializing
    
    init(request: ContentFeedRequest) {
        self.request = request
    }
    
    convenience init(url: NSURL) {
        self.init(request: ContentFeedRequest(url: url))
    }
    
    // MARK: - Output
    
    private(set) var items: [ContentModel]?
    private(set) var refreshStage: RefreshStage?
    
    // MARK: - Executing
    
    let request: ContentFeedRequest
    
    override func main() {
        requestExecutor.executeRequest(request, onComplete: { [weak self] items, refreshStage in
            // Map is a workaround for a compiler quirk. A crash will occur at runtime if we don't do it.
            self?.items = items.map { $0 as ContentModel }
            self?.refreshStage = refreshStage
        }, onError: nil)
    }
}
