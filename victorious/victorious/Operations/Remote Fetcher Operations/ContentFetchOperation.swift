//
//  ContentFetchOperation.swift
//  victorious
//
//  Created by Vincent Ho on 5/6/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ContentFetchOperation: RemoteFetcherOperation, RequestOperation {
    
    internal let request: ViewedContentFetchRequest!
    
    required init(request: ViewedContentFetchRequest) {
        self.request = request
    }
    
    convenience init(macroURLString: String,
                      currentUserID: String,
                      contentID: String) {
        
        let request = ViewedContentFetchRequest(macroURLString: macroURLString,
                                          currentUserID: currentUserID,
                                          contentID: contentID)
        self.init(request: request)
    }
    
    override func main() {
        requestExecutor.executeRequest(request, onComplete: onComplete, onError: nil)
    }
    
    func onComplete(result: ViewedContentFetchRequest.ResultType) {
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            let content: VContent = context.v_findOrCreateObject( [ "remoteID" : result.content.id ] )

            content.populate(fromSourceModel: result)
            context.v_save()
            let contentID = content.objectID

            self.persistentStore.mainContext.v_performBlockAndWait() { context in
                self.results = [ context.objectWithID(contentID) ]
            }
        }
    }
}
