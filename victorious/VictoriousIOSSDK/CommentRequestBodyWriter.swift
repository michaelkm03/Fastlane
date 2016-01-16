//
//  CommentRequestBodyWriter.swift
//  victorious
//
//  Created by Patrick Lynch on 12/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

class CommentRequestBodyWriter: NSObject, RequestBodyWriterType {
    
    struct RequestBody: RequestBodyType {
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
    
    func write( parameters parameters: Comment.CreationParameters ) throws -> RequestBody {
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
        return RequestBody(fileURL: bodyTempFile, contentType: writer.contentTypeHeader() )
    }
}
