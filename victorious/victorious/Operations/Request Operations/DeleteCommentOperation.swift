//
//  DeleteCommentOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 2/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class DeleteCommentOperation: FetcherOperation {
    
    let commentID: Int
    
    private let flaggedContent = VFlaggedContent()
    
    init(commentID: Int, removalReason: String?) {
        self.commentID = commentID
        super.init()
        
        let remoteOperation = DeleteCommentRemoteOperation(commentID: commentID, removalReason: removalReason)
        remoteOperation.queueAfter(self)
    }
    
    override func main() {
        // We're also going to flag it locally so that we can filter it from backend responses
        // while parsing in the future.
        flaggedContent.addRemoteId( String(self.commentID), toFlaggedItemsWithType: .Comment)
        
        // Perform data changes optimistically
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            let uniqueElements = [ "remoteId" : self.commentID ]
            if let comment: VComment = context.v_findObjects( uniqueElements ).first {
                comment.sequence?.commentCount -= 1
                context.deleteObject( comment )
                context.v_save()
            }
        }
    }
}

class DeleteCommentRemoteOperation: RequestOperation {
    
    var request: DeleteCommentRequest
    
    init( commentID: Int, removalReason: String?) {
        self.request = DeleteCommentRequest(commentID: commentID, removalReason: removalReason)
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: onComplete, onError: onError)
    }
    
    private func onError( error: NSError, completion:()->() ) {
        let params = [ VTrackingKeyErrorMessage : error.localizedDescription ?? "" ]
        VTrackingManager.sharedInstance().trackEvent( VTrackingEventFlagCommentDidFail, parameters:params)
        completion()
    }
    
    private func onComplete( response: FlagCommentRequest.ResultType, completion:()->() ) {
        VTrackingManager.sharedInstance().trackEvent( VTrackingEventUserDidFlagComment)
        completion()
    }
}
