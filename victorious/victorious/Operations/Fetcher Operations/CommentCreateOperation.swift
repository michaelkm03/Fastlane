//
//  CommentCreateOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

// Creates a local comment in the persistent store and then queues `CommentCreateRemoteOperation` when
// complete to send the comment to the Victorious backend
class CommentCreateOperation: FetcherOperation {
    
    private let creationParameters: Comment.CreationParameters
    
    init( creationParameters: Comment.CreationParameters) {
        self.creationParameters = creationParameters
    }
    
    override func main() {
        // Optimistically create a comment before sending request
        let newCommentObjectID: NSManagedObjectID? = persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            
            let sequenceID = self.creationParameters.sequenceID
            guard let sequence: VSequence = context.v_findObjects( [ "remoteId" : self.creationParameters.sequenceID ] ).first,
                let currentUser = VCurrentUser.user(inManagedObjectContext: context) else {
                    return nil
            }
            
            let creationDate = NSDate()
            
            let predicate = NSPredicate( format: "sequence.remoteId == %@", argumentArray: [sequenceID])
            let newDisplayOrder = context.v_displayOrderForNewObjectWithEntityName(VComment.v_entityName(), predicate: predicate)
            
            let comment: VComment = context.v_createObject()
            comment.sequenceId = String(sequenceID)
            comment.userId = currentUser.remoteId.integerValue
            comment.user = VCurrentUser.user(inManagedObjectContext: context)
            if let realtimeAttachment = self.creationParameters.realtimeAttachment {
                comment.realtime = NSNumber(float: Float(realtimeAttachment.time))
            }
            comment.text = self.creationParameters.text ?? ""
            comment.postedAt = creationDate
            comment.displayOrder = newDisplayOrder
            
            if let mediaAttachment = self.creationParameters.mediaAttachment,
                let thumbnailURL = mediaAttachment.createThumbnailImage() {
                    comment.mediaType = mediaAttachment.type.rawValue
                    comment.mediaUrl = mediaAttachment.url.absoluteString
                    comment.thumbnailUrl = thumbnailURL.absoluteString
                    comment.mediaWidth = mediaAttachment.size?.width
                    comment.mediaHeight = mediaAttachment.size?.height
                    comment.shouldAutoplay = mediaAttachment.shouldAutoplay
            }
            
            let allComments = [comment] + sequence.comments.array as? [VComment] ?? []
            sequence.comments = NSOrderedSet(array: allComments)
            sequence.commentCount += 1
            
            context.v_save()
            return comment.objectID
        }
        
        if let newCommentObjectID = newCommentObjectID,
            let remoteOperation = CommentCreateRemoteOperation(localCommentID: newCommentObjectID, creationParameters: self.creationParameters) {
                remoteOperation.after(self).queue()
        }
        
        VTrackingManager.sharedInstance().trackEvent( VTrackingEventUserDidPostComment,
            parameters: [
                VTrackingKeyTextLength : self.creationParameters.text?.characters.count ?? 0,
                VTrackingKeyMediaType : self.creationParameters.mediaAttachment?.url.absoluteString ?? ""
            ]
        )
    }
}
