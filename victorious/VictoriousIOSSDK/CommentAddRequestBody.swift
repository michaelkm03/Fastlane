//
//  CommentAddRequestBody.swift
//  victorious
//
//  Created by Patrick Lynch on 12/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

/// An object that handles writing multipart form input for POST methods for /api/comment/add endpoint
class CommentAddRequestBody: NSObject {
    
    struct Output {
        let fileURL: NSURL
        let contentType: String
    }
    
    private var bodyTempFile: NSURL = {
        let tempDirectory = NSURL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        return tempDirectory.URLByAppendingPathComponent(NSUUID().UUIDString)
    }()
    
    deinit {
        let _ = try? NSFileManager.defaultManager().removeItemAtURL(bodyTempFile)
    }
    
    /// Writes a post body for an HTTP request to a temporary file and returns the URL of that file.
    func write( parameters parameters: Comment.CreationParameters ) throws -> Output {
        let writer = VMultipartFormDataWriter(outputFileURL: bodyTempFile)
        
        try writer.appendPlaintext(String(parameters.sequenceID), withFieldName: "sequence_id")
        
        if let text = parameters.text {
            try writer.appendPlaintext(text, withFieldName: "text")
        }
        
        if let commentID = parameters.replyToCommentID {
            try writer.appendPlaintext( String(commentID), withFieldName: "parent_id")
        }
        
        if let realtimeAttachment = parameters.realtimeAttachment {
            try writer.appendPlaintext( String(realtimeAttachment.assetID), withFieldName: "asset_id" )
            try writer.appendPlaintext( String(realtimeAttachment.time), withFieldName: "realtime" )
        }
        
        if let mediaAttachment = parameters.mediaAttachment,
            let pathExtension = mediaAttachment.url.pathExtension,
            let mimeType = mediaAttachment.url.vsdk_mimeType {
                try writer.appendFileWithName("media_data.\(pathExtension)",
                    contentType: mimeType,
                    fileURL: mediaAttachment.url,
                    fieldName: "media_data"
                )
        }
        
        try writer.finishWriting()
        
        return Output(fileURL: bodyTempFile, contentType: writer.contentTypeHeader() )
    }
}