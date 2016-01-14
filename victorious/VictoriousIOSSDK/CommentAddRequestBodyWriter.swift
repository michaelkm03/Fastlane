//
//  CommentAddRequestBodyWriter.swift
//  victorious
//
//  Created by Tian Lan on 1/13/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// An object that handles writing multipart form input for POST methods for /api/comment/add endpoint
class CommentAddRequestBodyWriter: RequestBodyWriter {
    
    var bodyTempFile: NSURL {
        return createBodyTempFile()
    }
    
    /// Writes a post body for an HTTP request to a temporary file and returns the URL of that file.
    func write( parameters parameters: CommentParameters ) throws -> RequestBodyWriterOutput {
        let writer = VMultipartFormDataWriter(outputFileURL: bodyTempFile)
        
        try writer.appendPlaintext( parameters.sequenceID, withFieldName: "sequence_id")
        
        if let text = parameters.text {
            try writer.appendPlaintext(text, withFieldName: "text")
        }
        
        if let commentID = parameters.replyToCommentID {
            try writer.appendPlaintext( String(commentID), withFieldName: "parent_id")
        }
        
        if let realtime = parameters.realtimeComment {
            try writer.appendPlaintext( String(realtime.assetID), withFieldName: "asset_id" )
            try writer.appendPlaintext( String(realtime.time), withFieldName: "realtime" )
        }
        
        if let mediaURL = parameters.mediaURL,
            let pathExtension = mediaURL.pathExtension,
            let mimeType = mediaURL.vsdk_mimeType {
                try writer.appendFileWithName("media_data.\(pathExtension)",
                    contentType: mimeType,
                    fileURL: mediaURL,
                    fieldName: "media_data"
                )
        }
        
        try writer.finishWriting()
        
        return RequestBodyWriterOutput(fileURL: bodyTempFile, contentType: writer.contentTypeHeader() )
    }
}
