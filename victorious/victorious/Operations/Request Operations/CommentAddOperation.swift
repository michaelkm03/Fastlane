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
    
    var request: CommentAddRequest!
    
    private var creationParameters: Comment.CreationParameters
    
    private var optimisticCommentObjectID: NSManagedObjectID?
    
    private init( request: CommentAddRequest, creationParameters: Comment.CreationParameters) {
        self.request = request
        self.creationParameters = creationParameters
    }
    
    required init?( creationParameters: Comment.CreationParameters) {
        self.request = CommentAddRequest(parameters: creationParameters)
        self.creationParameters = creationParameters
        
        if request == nil { return }
    }
    
    override func main() {
        
        // Optimistically create a comment before sending request
        let commentCreationDidSucceed: Bool = persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            
            guard let currentUser = VCurrentUser.user(inManagedObjectContext: context) else {
                return false
            }
            
            let comment: VComment = context.v_createObject()
            comment.sequenceId = String(self.creationParameters.sequenceID)
            comment.userId = currentUser.remoteId.integerValue
            comment.user = VCurrentUser.user(inManagedObjectContext: context)
            if let realtimeAttachment = self.creationParameters.realtimeAttachment {
                comment.realtime = NSNumber(float: Float(realtimeAttachment.time))
            }
            comment.text = self.creationParameters.text ?? ""
            comment.postedAt = NSDate()
            
            if let mediaAttachment = self.creationParameters.mediaAttachment {
                comment.mediaType = mediaAttachment.type.rawValue
                comment.mediaUrl = mediaAttachment.url.absoluteString
                comment.thumbnailUrl = mediaAttachment.thumbnailURL.absoluteString
                comment.mediaWidth = mediaAttachment.size?.width
                comment.mediaHeight = mediaAttachment.size?.height
            }
            
            // Prepend comment to beginning of comments ordered set so that it shows up at the top of comment feeds
            let sequence: VSequence = context.v_findOrCreateObject( ["remoteId" : String(self.creationParameters.sequenceID)] )
            let allComments = [comment] + sequence.comments.array as? [VComment] ?? []
            sequence.comments = NSOrderedSet(array: allComments)
            
            context.v_save()
            dispatch_sync( dispatch_get_main_queue() ) {
                self.optimisticCommentObjectID = comment.objectID
            }
            return true
        }
        
        guard commentCreationDidSucceed else {
            return
        }
        requestExecutor.executeRequest( request, onComplete: nil, onError: nil )
        
        VTrackingManager.sharedInstance().trackEvent( VTrackingEventUserDidPostComment,
            parameters: [
                VTrackingKeyTextLength : self.creationParameters.text?.characters.count ?? 0,
                VTrackingKeyMediaType : self.creationParameters.mediaAttachment?.url.absoluteString ?? ""
            ]
        )
    }
    
    private func onComplete( comment: CommentAddRequest.ResultType, completion:()->() ) {
        
        storedBackgroundContext = persistentStore.createBackgroundContext().v_performBlock() { context in
            defer {
                completion()
            }
            
            guard let objectID = self.optimisticCommentObjectID,
                let optimisticComment = context.objectWithID( objectID ) as? VComment else {
                    return
            }
            
            // Repopulate the comment after created on server to provide remoteId and other properties
            optimisticComment.populate( fromSourceModel: comment )
            context.v_save()
            completion()
        }
    }
}
