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
        
        persistentStore.asyncFromBackground() { context in
            // Optimistically create a comment before sending request
            let comment: VComment = context.createObject()
            comment.realtime = { if let time = self.currentTime { return NSNumber(float: Float(time)) } else { return nil } }()
            //comment.mediaWidth = publishParameters.width
            //comment.mediaHeight = publishParameters.height
            comment.text = self.text ?? ""
            comment.postedAt = NSDate()
            comment.sequenceId = String(self.sequenceID)
            //comment.thumbnailUrl = mediaURL.absoluteString // see localImageURLForVideo:
            comment.mediaUrl = self.publishParameters?.mediaToUploadURL.absoluteString
            comment.userId = currentUserId
            
            context.saveChanges()
            completion()
        }
    }
    
    override func onComplete( comment:CommentAddRequest.ResultType, completion: () -> ()) {
        persistentStore.asyncFromBackground() { context in
            
            // Repopulate the comment after created on server to provide remoteId and other properties
            if let commentCreated: VComment = context.findObjects( [ "sequenceId" : String(comment.commentID)] ).first {
                commentCreated.populate( fromSourceModel: comment )
                context.saveChanges()
            }
            
            completion()
        }
    }
}
