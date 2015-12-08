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
    
    private var optimisticCommentIdentifier: AnyObject?
    
    init( commentParameters: CommentParameters, publishParameters: VPublishParameters? ) {
        self.commentParameters = commentParameters
        self.publishParameters = publishParameters
        
        if let request = CommentAddRequest(parameters: commentParameters) {
            self.request = request
        } else {
            fatalError( "Failed to create required request for operation." )
        }
    }
    
    override func main() {
        guard let currentUserId = VUser.currentUser()?.remoteId else {
            return
        }
        
        // Optimistically create a comment before sending request
        persistentStore.asyncFromBackground() { context in
            let comment: VComment = context.createObject()
            comment.remoteId = 0
            comment.sequenceId = String(self.commentParameters.sequenceID)
            comment.userId = currentUserId
            if let realtime = self.commentParameters.realtimeComment {
                comment.realtime = NSNumber(float: Float(realtime.time))
            }
            comment.mediaWidth = self.publishParameters?.width
            comment.mediaHeight = self.publishParameters?.height
            comment.text = self.commentParameters.text ?? ""
            comment.postedAt = NSDate()
            comment.thumbnailUrl = self.localImageURLForVideoAtPath( self.publishParameters?.mediaToUploadURL?.absoluteString ?? "" )
            comment.mediaUrl = self.publishParameters?.mediaToUploadURL?.absoluteString
            
            context.saveChanges()
            dispatch_sync( dispatch_get_main_queue() ) {
                self.optimisticCommentIdentifier = comment.identifier
            }
        }
        executeRequest( request, onComplete: self.onComplete )
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
    }
    
    private func localImageURLForVideoAtPath( localVideoPath: String ) -> String? {
        
        guard let url = NSURL(string:localVideoPath) else {
            return nil
        }
        
        guard !localVideoPath.v_hasImageExtension() else {
            return localVideoPath
        }
        
        let asset = AVAsset(URL: url)
        let assetGenerator = AVAssetImageGenerator(asset: asset)
        let time = CMTimeMake(asset.duration.value / 2, asset.duration.timescale)
        let anImageRef: CGImageRef?
        do {
            anImageRef = try assetGenerator.copyCGImageAtTime(time, actualTime: nil)
        } catch {
            return nil
        }
        
        guard let imageRef = anImageRef else {
            return nil
        }
        let previewImage = UIImage(CGImage: imageRef)
        
        let tempDirectory = NSURL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let tempFile = tempDirectory.URLByAppendingPathComponent(NSUUID().UUIDString).URLByAppendingPathExtension(VConstantMediaExtensionJPG)
        if let imgData = UIImageJPEGRepresentation(previewImage, VConstantJPEGCompressionQuality) {
            imgData.writeToURL(tempFile, atomically: false )
            return tempFile.absoluteString
        }
        
        return nil
    }
}
