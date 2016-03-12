//
//  CommentFlagRemoteOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class CommentFlagRemoteOperation: RemoteFetcherOperation, RequestOperation {
    
    let request: FlagCommentRequest!
    
    init( commentID: Int ) {
        self.request = FlagCommentRequest(commentID: commentID)
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: onComplete, onError: onError)
    }
    
    private func onError( error: NSError) {
        let params = [ VTrackingKeyErrorMessage : error.localizedDescription ?? "" ]
        VTrackingManager.sharedInstance().trackEvent( VTrackingEventFlagCommentDidFail, parameters:params)
    }
    
    private func onComplete( response: FlagCommentRequest.ResultType) {
        VTrackingManager.sharedInstance().trackEvent( VTrackingEventUserDidFlagComment)
    }
}
