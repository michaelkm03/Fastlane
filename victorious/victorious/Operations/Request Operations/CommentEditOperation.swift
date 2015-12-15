//
//  CommentEditOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 12/15/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class CommentEditOperation: RequestOperation {
    
    var request: CommentEditRequest
    
    private let text: String
    private let commentID: Int64
    
    private var optimisticCommentIdentifier: AnyObject?
    
    init( commentID: Int64, text: String ) {
        self.commentID = commentID
        self.text = text
        self.request = CommentEditRequest(commentID: commentID, text: text)
    }
    
    override func main() {
        
        // Optimistically edit the comment before sending request
        persistentStore.asyncFromBackground() { context in
            if let comment: VComment = context.findObjects( ["remoteId" : NSNumber(longLong:self.commentID)] ).first {
                comment.text = self.text
                context.saveChanges()
                dispatch_sync( dispatch_get_main_queue() ) {
                    self.optimisticCommentIdentifier = comment.identifier
                }
            }
        }
        
        // Then fire and forget
        executeRequest( request, onComplete: self.onComplete )
    }
    
    private func onError( error: NSError, completion:()->() ) {
        let params = [ VTrackingKeyErrorMessage : error.localizedDescription ?? "" ]
        VTrackingManager.sharedInstance().trackEvent( VTrackingEventEditCommentDidFail, parameters:params)
        completion()
    }
    
    private func onComplete( comment: CommentAddRequest.ResultType, completion:()->() ) {
        persistentStore.asyncFromBackground() { context in
            
            guard let identifier = self.optimisticCommentIdentifier,
                let optimisticComment: VComment = context.getObject( identifier ) else {
                    fatalError( "Failed to load comment create optimistically during operation's execution." )
            }
            
            // Repopulate the comment after created on server to provide remoteId and other properties
            optimisticComment.populate( fromSourceModel: comment )
            context.saveChanges()
            completion()
        }
        
        VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserDidCompleteEditComment)
    }
}
