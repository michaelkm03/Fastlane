//
//  CommentAddOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 12/1/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class CommentAddOperation: RequestOperation {
    
    var request: CommentAddRequest
    
    private let publishParameters: VPublishParameters?
    private let commentParameters: CommentParameters
    
    private var optimisticObjectID: NSManagedObjectID?
    
    private init( request: CommentAddRequest, commentParameters: CommentParameters, publishParameters: VPublishParameters?) {
        self.request = request
        self.commentParameters = commentParameters
        self.publishParameters = publishParameters
    }
    
    convenience init?( commentParameters: CommentParameters, publishParameters: VPublishParameters? ) {
        if let request = CommentAddRequest(parameters: commentParameters) {
            self.init(request: request, commentParameters: commentParameters, publishParameters: publishParameters)
        } else {
            return nil
        }
    }
    
    override func main() {
        guard let currentUserId = VCurrentUser.user()?.remoteId else {
            return
        }
        
        // Optimistically create a comment before sending request
        persistentStore.backgroundContext.v_performBlock() { context in
            let comment: VComment = context.v_createObject()
            comment.remoteId = 0
            comment.sequenceId = String(self.commentParameters.sequenceID)
            comment.userId = currentUserId
            comment.user = VCurrentUser.user()
            if let realtime = self.commentParameters.realtimeComment {
                comment.realtime = NSNumber(float: Float(realtime.time))
            }
            comment.mediaWidth = self.publishParameters?.width
            comment.mediaHeight = self.publishParameters?.height
            comment.text = self.commentParameters.text ?? ""
            comment.postedAt = NSDate()
            
            let mediaPath = self.publishParameters?.mediaToUploadURL?.absoluteString ?? ""
            comment.thumbnailUrl = mediaPath.v_thumbnailPathForVideoAtPath
            comment.mediaUrl = mediaPath
            
            // Prepend comment to beginning of comments ordered set so that it shows up at the top of comment feeds
            let sequence: VSequence = context.v_findOrCreateObject( ["remoteId" : String(self.commentParameters.sequenceID)] )
            let allComments = [comment] + sequence.comments.array as? [VComment] ?? []
            sequence.comments = NSOrderedSet(array: allComments)
            
            context.v_save()
            dispatch_sync( dispatch_get_main_queue() ) {
                self.optimisticObjectID = comment.objectID
            }
        }
        requestExecutor.executeRequest( request, onComplete: onComplete, onError: nil )
        
        VTrackingManager.sharedInstance().trackEvent( VTrackingEventUserDidPostComment,
            parameters: [
                VTrackingKeyTextLength : self.commentParameters.text?.characters.count ?? 0,
                VTrackingKeyMediaType : self.publishParameters?.mediaToUploadURL?.pathExtension ?? ""
            ]
        )
    }
    
    private func onComplete( comment: CommentAddRequest.ResultType, completion:()->() ) {
        
        persistentStore.backgroundContext.v_performBlock() { context in
            defer { completion() }
            
            guard let objectID = self.optimisticObjectID,
                let optimisticObject = context.objectWithID( objectID ) as? VComment else {
                    return
            }
            
            // Repopulate the comment after created on server to provide remoteId and other properties
            optimisticObject.populate( fromSourceModel: comment )
            context.v_save()
        }
    }
}
