//
//  CommentRequestBodyWriter.swift
//  victorious
//
//  Created by Patrick Lynch on 12/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

class CommentRequestBodyWriter: NSObject, RequestBodyWriterType {
    
    struct Output {
        let fileURL: NSURL
        let contentType: String
    }
    
    let parameters:  Comment.CreationParameters
    
    init( parameters: Comment.CreationParameters ) {
        self.parameters = parameters
    }
    
    deinit {
        removeBodyTempFile()
    }
    
    func write() throws -> Output {
        
        let writer = VMultipartFormDataWriter(outputFileURL: bodyTempFileURL)
        
        try writer.appendPlaintext(String(parameters.sequenceID), withFieldName: "sequence_id")
        
        if let text = parameters.text {
            try writer.appendPlaintext(text, withFieldName: "text")
        }
        
        if let commentID = parameters.replyToCommentID {
            try writer.appendPlaintext( String(commentID), withFieldName: "parent_id")
        }
        
        if let realtimeAttachment = parameters.realtimeAttachment {
            try writer.appendPlaintext( String(realtimeAttachment.time), withFieldName: "realtime" )
        }
        
        if let mediaAttachment = parameters.mediaAttachment,
            let pathExtension = mediaAttachment.url.pathExtension,
            let mimeType = mediaAttachment.url.vsdk_mimeType {
                
                let isGIFStyleValue = mediaAttachment.type == .GIF ? "true" : "false"
                try writer.appendPlaintext(isGIFStyleValue, withFieldName: "is_gif_style")
                
                let mediaTypeValue: String
                switch mediaAttachment.type {
                case .Video, .GIF:
                    mediaTypeValue = MediaAttachmentType.Video.rawValue
                case .Image:
                    mediaTypeValue = MediaAttachmentType.Image.rawValue
                default:
                    mediaTypeValue = ""
                }
                try writer.appendPlaintext(mediaTypeValue, withFieldName: "media_type")
                
                try writer.appendFileWithName("media_data.\(pathExtension)",
                    contentType: mimeType,
                    fileURL: mediaAttachment.url,
                    fieldName: "media_data"
                )
        }
        
        try writer.finishWriting()
        
        return Output(fileURL: bodyTempFileURL, contentType: writer.contentTypeHeader() )
    }
}
