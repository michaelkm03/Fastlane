//
//  SendMessageRequest.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Sends a message to a recipient.
public class SendMessageRequest: RequestType {
    
    public let recipientID: Int
    public let text: String?
    public let mediaAttachment: MediaAttachment?
    
    public private(set) var urlRequest = NSURLRequest()
    
    private var bodyTempFile: NSURL?
    
    public init?(recipientID: Int, text: String?, mediaAttachment: MediaAttachment?) {
        
        self.recipientID = recipientID
        self.text = text
        self.mediaAttachment = mediaAttachment
        
        do {
            self.urlRequest = try makeRequest()
        } catch {
            return nil
        }
    }
    
    deinit {
        if let bodyTempFile = bodyTempFile {
            let _ = try? NSFileManager.defaultManager().removeItemAtURL(bodyTempFile)
        }
    }
    
    private func makeRequest() throws -> NSURLRequest {
        let bodyTempFile = self.tempFile()
        let writer = VMultipartFormDataWriter(outputFileURL: bodyTempFile)
        
        try writer.appendPlaintext(text ?? "", withFieldName: "text")
        try writer.appendPlaintext(String(recipientID), withFieldName: "to_user_id")
        
        if let mediaAttachment = self.mediaAttachment, let mimeType = mediaAttachment.url.vsdk_mimeType {
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
        self.bodyTempFile = bodyTempFile
        
        let request = NSMutableURLRequest(URL: NSURL(string: "/api/message/send")!)
        request.HTTPMethod = "POST"
        request.HTTPBodyStream = NSInputStream(URL: bodyTempFile)
        return request
    }
    
    private func tempFile() -> NSURL {
        let tempDirectory = NSURL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        return tempDirectory.URLByAppendingPathComponent(NSUUID().UUIDString)
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> (conversationID: Int, messageID: Int) {
        let payload = responseJSON["payload"]
        guard let conversationID = Int(payload["conversation_id"].string ?? ""),
            let messageID = payload["message_id"].int else {
                throw ResponseParsingError()
        }
        return (conversationID, messageID)
    }
}
