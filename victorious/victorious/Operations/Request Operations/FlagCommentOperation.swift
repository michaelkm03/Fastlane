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
    
    private let commentID: Int
    private let flaggedContent = VFlaggedContent()
    
    init( commentID: Int ) {
        self.commentID = commentID
        self.request = FlagCommentRequest(commentID: commentID)
    }
    
    override func main() {
        flaggedContent.addRemoteId( String(self.commentID), toFlaggedItemsWithType: .Comment)
        
        // Perform data changes optimistically
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            let uniqueElements = [ "remoteId" : self.commentID ]
            if let comment: VComment = context.v_findObjects( uniqueElements ).first {
                context.deleteObject( comment )
                context.v_save()
            }
        }
        
        // Execute request with callbacks
        requestExecutor.executeRequest( request, onComplete: self.onComplete, onError: self.onError)
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
