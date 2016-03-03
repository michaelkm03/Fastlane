//
//  CommentEditRemoteOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class CommentEditRemoteOperation: RemoteFetcherOperation, RequestOperation {
    
    var request: CommentEditRequest!
    
    private var optimisticObjectID: NSManagedObjectID?
    
    init( commentID: Int, text: String ) {
        self.request = CommentEditRequest(commentID: commentID, text: text)
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: onComplete, onError: nil )
    }
    
    private func onError( error: NSError, completion:()->() ) {
        let params = [ VTrackingKeyErrorMessage : error.localizedDescription ?? "" ]
        VTrackingManager.sharedInstance().trackEvent( VTrackingEventEditCommentDidFail, parameters:params)
        completion()
    }
    
    private func onComplete( comment: CommentAddRequest.ResultType, completion:()->() ) {
        
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            defer {
                completion()
            }
            
            guard let objectID = self.optimisticObjectID,
                let optimisticObject = context.objectWithID( objectID ) as? VComment else {
                    return
            }
            
            // Repopulate the comment after created on server to provide remoteId and other properties
            optimisticObject.populate( fromSourceModel: comment )
            context.v_save()
            completion()
        }
        
        VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserDidCompleteEditComment)
    }
}
