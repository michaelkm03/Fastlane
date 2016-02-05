//
//  FlagCommentOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/24/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class FlagCommentOperation: RequestOperation {
    
    var request: FlagCommentRequest
    
    private let flaggedContent = VFlaggedContent()
    
    init( commentID: Int ) {
        self.request = FlagCommentRequest(commentID: commentID)
        super.init()
        
        let remoteOperation = FlagCommentRemoteOperation(commentID: commentID)
        remoteOperation.queueAfter( self )
    }
    
    override func main() {
        flaggedContent.addRemoteId( String(self.request.commentID), toFlaggedItemsWithType: .Comment)
        
        // Perform data changes optimistically
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            let uniqueElements = [ "remoteId" : self.request.commentID ]
            if let comment: VComment = context.v_findObjects( uniqueElements ).first {
                comment.sequence?.commentCount -= 1
                context.deleteObject( comment )
                context.v_save()
            }
        }
    }
}


class FlagCommentRemoteOperation: RequestOperation {
    
    var request: FlagCommentRequest
    
    init( commentID: Int ) {
        self.request = FlagCommentRequest(commentID: commentID)
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
