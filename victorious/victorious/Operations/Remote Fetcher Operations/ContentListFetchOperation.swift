//
//  ContentListFetchOperation.swift
//  victorious
//
//  Created by Jarod Long on 5/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class ContentListFetchOperation: RemoteFetcherOperation, RequestOperation {
    // MARK: - Initializing
    
    required init(request: ContentListFetchRequest) {
        self.request = request
    }
    
    convenience init(urlString: String, fromTime: NSDate) {
        self.init(request: ContentListFetchRequest(urlString: urlString, fromTime: fromTime))
    }
    
    // MARK: - Request
    
    let request: ContentListFetchRequest!
    
    // MARK: - Executing
    
    override func main() {
        requestExecutor.executeRequest(request, onComplete: onComplete, onError: nil)
    }
    
    func onComplete(contents: ContentListFetchRequest.ResultType) {
        persistentStore.createBackgroundContext().v_performBlockAndWait() { [weak self] context in
            let managedContentIDs: [NSManagedObjectID] = contents.map { content in
                let managedContent: VContent = context.v_findOrCreateObject([
                    "remoteID": content.content.id,
                    "author.remoteId": content.author.userID
                ])
                
                managedContent.populate(fromSourceModel: content)
                
                return managedContent.objectID
            }
            
            context.v_save()
            
            self?.persistentStore.mainContext.v_performBlockAndWait() { context in
                self?.results = managedContentIDs.flatMap {
                    context.objectWithID($0)
                }
            }
        }
    }
}
