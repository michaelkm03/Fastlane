//
//  ContentFeedOperation.swift
//  victorious
//
//  Created by Vincent Ho on 5/17/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class ContentFeedOperation: NSOperation, Queueable {
    
    // MARK: - Initializing
    
    init(url: NSURL) {
        remoteOperation = ContentFeedRemoteOperation(url: url)
        super.init()
        queuePriority = .VeryHigh
        remoteOperation.before(self).queue()
    }
    
    // MARK: - Fetched content
    
    private let remoteOperation: ContentFeedRemoteOperation
    private var items: [ContentModel]?
    private var error: NSError?
    private var stageEvent: ForumEvent?
    
    // MARK: - Executing
    
    override func main() {
        guard error == nil && !cancelled else {
            return
        }
        
        items = remoteOperation.items
        error = remoteOperation.error
        
        if let refreshStage = remoteOperation.refreshStage {
            stageEvent = .refreshStage(refreshStage)
        } else {
            stageEvent = .closeStage(.main)
        }
    }
    
    func executeCompletionBlock(completionBlock: (newItems: [ContentModel], stageEvent: ForumEvent?, error: NSError?) -> Void) {
        dispatch_async(dispatch_get_main_queue()) {
            completionBlock(newItems: self.items ?? [], stageEvent: self.stageEvent, error: self.error)
        }
    }
}
