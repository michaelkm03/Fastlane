//
//  MessageRequestBodyWriter.swift
//  victorious
//
//  Created by Patrick Lynch on 1/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class MessageRequestBodyWriter: NSObject, RequestBodyWriterType {
    
    struct Output {
        let fileURL: NSURL
        let contentType: String
    }
    
    let parameters:  Message.CreationParameters
    
    init( parameters: Message.CreationParameters ) {
        self.parameters = parameters
    }
    
    deinit {
        removeBodyTempFile()
    }
    
    func write() throws -> Output {
        
        let writer = VMultipartFormDataWriter(outputFileURL: bodyTempFileURL)
        
        try writer.appendPlaintext(parameters.text ?? "", withFieldName: "text")
        try writer.appendPlaintext(String(parameters.recipientID) ?? "", withFieldName: "to_user_id")
        
        if let mediaAttachment = parameters.mediaAttachment, let mimeType = mediaAttachment.url.vsdk_mimeType {
            if mediaAttachment.type == .GIF {
                try writer.appendPlaintext("true", withFieldName: "is_gif_style")
            }
            try writer.appendFileWithName("message_media.\(mediaAttachment.url.pathExtension)",
                contentType: mimeType,
                fileURL: mediaAttachment.url,
                fieldName: "media_data"
            )
        }
        
        try writer.finishWriting()
        
        return Output(fileURL: bodyTempFileURL, contentType: writer.contentTypeHeader() )
    }
}
