//
//  CommentDeleteRemoteOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class CommentDeleteRemoteOperation: RemoteFetcherOperation, RequestOperation {
    
    let request: DeleteCommentRequest!
    
    init( commentID: Int, removalReason: String?) {
        self.request = DeleteCommentRequest(commentID: commentID, removalReason: removalReason)
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: onComplete, onError: onError)
    }
    
    private func onError( error: NSError) {
        let params = [ VTrackingKeyErrorMessage : error.localizedDescription ?? "" ]
        VTrackingManager.sharedInstance().trackEvent( VTrackingEventFlagCommentDidFail, parameters: params)
    }
    
    private func onComplete( response: FlagCommentRequest.ResultType) {
        VTrackingManager.sharedInstance().trackEvent( VTrackingEventUserDidFlagComment)
    }
}
