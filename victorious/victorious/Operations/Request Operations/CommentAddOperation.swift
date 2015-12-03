//
//  CommentAddOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 12/1/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

private extension VPublishParameters {
    var commentMediaAttachmentType: MediaAttachmentType {
        if self.isGIF {
            return .GIF
        } else if self.isVideo {
            return .Video
        }
        return .Image
    }
}

class CommentAddOperation: RequestOperation<CommentAddRequest> {
    
    private let persistentStore: PersistentStoreType = MainPersistentStore()
    private let publishParameters: VPublishParameters?
    private let sequenceID: Int64
    private let currentTime: Float64?
    private let text: String?
    
    private var optimisticCommentIdentifier: AnyObject?
    
    init( sequenceID: Int64, text: String?, publishParameters: VPublishParameters?, currentTime: Float64? ) {
        self.sequenceID = sequenceID
        self.currentTime = currentTime
        self.publishParameters = publishParameters
        self.text = text
        let request = CommentAddRequest(
            sequenceID: sequenceID,
            text: text,
            mediaAttachmentType: publishParameters?.commentMediaAttachmentType,
            mediaURL: publishParameters?.mediaToUploadURL
        )
        super.init(request: request!)
    }
    
    override func onStart( completion:()->() ) {
        guard let currentUserId = VUser.currentUser()?.remoteId else {
            completion()
            return
        }
        
        // TODO: Finish add comment
        persistentStore.asyncFromBackground() { context in
            // Optimistically create a comment before sending request
            let comment: VComment = context.createObject()
            comment.remoteId = 0
            comment.sequenceId = String(self.sequenceID)
            comment.userId = currentUserId
            comment.realtime = { if let time = self.currentTime { return NSNumber(float: Float(time)) } else { return nil } }()
            //comment.mediaWidth = publishParameters.width
            //comment.mediaHeight = publishParameters.height
            comment.text = self.text ?? ""
            comment.postedAt = NSDate()
            //comment.thumbnailUrl = mediaURL.absoluteString // see localImageURLForVideo:
            comment.mediaUrl = self.publishParameters?.mediaToUploadURL.absoluteString
            context.saveChanges()
            dispatch_sync( dispatch_get_main_queue() ) {
                self.optimisticCommentIdentifier = comment.identifier
            }
            completion()
        }
    }
    
    override func onComplete( comment: CommentAddRequest.ResultType, completion: () -> ()) {
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
    }
}
