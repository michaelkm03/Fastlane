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
    
    private let recipientID: Int64
    private let text: String?
    private let mediaURL: NSURL?
    private let mediaType: MediaAttachmentType?
    
    public private(set) var urlRequest = NSURLRequest()
    
    private var bodyTempFile: NSURL?
    
    private func makeRequest() throws -> NSURLRequest {
        let bodyTempFile = self.tempFile()
        let writer = VMultipartFormDataWriter(outputFileURL: bodyTempFile)
        
        try writer.appendPlaintext(text ?? "", withFieldName: "text")
        try writer.appendPlaintext("\(recipientID)", withFieldName: "to_user_id")
        
        if let mediaURL = mediaURL,
            let mediaType = mediaType,
            let pathExtension = mediaURL.pathExtension,
            let mimeType = mediaURL.vsdk_mimeType {
                if mediaType == .GIF {
                    try writer.appendPlaintext("true", withFieldName: "is_gif_style")
                }
                try writer.appendFileWithName("message_media.\(pathExtension)", contentType: mimeType, fileURL: mediaURL, fieldName: "media_data")
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
    
    public init?(recipientID: Int64, text: String?, mediaAttachmentType: MediaAttachmentType?, mediaURL: NSURL?) {
        
        self.recipientID = recipientID
        self.text = text
        self.mediaType = mediaAttachmentType
        self.mediaURL = mediaURL
        
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
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> (conversationID: Int64, messageID: Int64) {
        let payload = responseJSON["payload"]
        guard let conversationID = Int64(payload["conversation_id"].string ?? ""),
            let messageID = payload["message_id"].int64 else {
                throw ResponseParsingError()
        }
        return (conversationID, messageID)
    }
}
