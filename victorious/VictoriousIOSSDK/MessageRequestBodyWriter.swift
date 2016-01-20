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
