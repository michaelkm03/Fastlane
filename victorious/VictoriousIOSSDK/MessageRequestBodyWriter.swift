//
//  MessageRequestBodyWriter.swift
//  victorious
//
//  Created by Patrick Lynch on 1/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class MessageRequestBodyWriter: NSObject, RequestBodyWriterType {
    
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
    
    func write( parameters parameters: Message.CreationParameters ) throws -> RequestBody {
        let writer = VMultipartFormDataWriter(outputFileURL: bodyTempFile)
        
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
        return RequestBody(fileURL: bodyTempFile, contentType: writer.contentTypeHeader() )
    }
}