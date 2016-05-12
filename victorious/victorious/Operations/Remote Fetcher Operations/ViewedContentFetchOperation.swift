//
//  ViewedContentFetchOperation.swift
//  victorious
//
//  Created by Vincent Ho on 5/6/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ViewedContentFetchOperation: RemoteFetcherOperation, RequestOperation {
    
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
            let viewedContent: VViewedContent = context.v_findOrCreateObject( [ "author.remoteId" : result.author.userID, "content.remoteID" : result.content.id ] )

            viewedContent.populate(fromSourceModel: result)
            context.v_save()
            let viewedContentID = viewedContent.objectID

            self.persistentStore.mainContext.v_performBlockAndWait() { context in
                self.results = [ context.objectWithID(viewedContentID) ]
            }
        }
    }
}
