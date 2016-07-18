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
        super.init()
        
        queuePriority = .VeryHigh
        
        let remoteOperation = ContentFeedRemoteOperation(url: url)
        remoteOperation.before(self).queue { [weak self] results, error, _ in
            self?.contentIDs = (results as? [String]) ?? []
            self?.error = error
            if let refreshStage = remoteOperation.refreshStage {
                self?.stageEvent = .refreshStage(refreshStage)
            } else {
                self?.stageEvent = .closeMainStage
            }
        }
    }
    
    // MARK: - Fetched content
    
    var contentIDs = [String]()
    var items = [ContentModel]()
    var error: NSError?
    private var stageEvent: ForumEvent?
    
    // MARK: - Executing
    
    override func main() {
        guard error == nil && !cancelled else {
            return
        }
        
        let persistentStore = PersistentStoreSelector.defaultPersistentStore
        
        persistentStore.mainContext.v_performBlockAndWait { [weak self] context in
            self?.items = self?.contentIDs.flatMap { contentID in
                if Content.contentIsHidden(withID: contentID) {
                    return nil
                }
                return context.v_findOrCreateObject(["v_remoteID": contentID]) as VContent
            } ?? []
        }
    }
    
    func executeCompletionBlock(completionBlock: (newItems: [ContentModel], stageEvent: ForumEvent?, error: NSError?) -> Void) {
        dispatch_async(dispatch_get_main_queue()) {
            completionBlock(newItems: self.items, stageEvent: self.stageEvent, error: self.error)
        }
    }
}
