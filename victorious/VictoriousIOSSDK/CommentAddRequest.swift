//
//  CommentAddRequest.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/12/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Adds a comment to a particular sequence
public class CommentAddRequest: RequestType {
    
    public let sequenceID: Int64
    public let text: String?
    public let mediaURL: NSURL?
    public let mediaType: MediaAttachmentType?
    
    public private(set) var urlRequest = NSURLRequest()
    
    private var bodyTempFile: NSURL?
    
    public init?(sequenceID: Int64, text: String?, mediaAttachmentType: MediaAttachmentType?, mediaURL: NSURL?) {
        self.sequenceID = sequenceID
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
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> Comment {
        guard let comment = Comment(json: responseJSON["payload"]) else {
            throw ResponseParsingError()
        }
        return comment
    }
    
    private func makeRequest() throws -> NSURLRequest {
        let bodyTempFile = self.tempFile()
        let writer = VMultipartFormDataWriter(outputFileURL: bodyTempFile)
        
        try writer.appendPlaintext(text ?? "", withFieldName: "text")
        try writer.appendPlaintext(String(sequenceID), withFieldName: "sequence_id")
        
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
        
        let request = NSMutableURLRequest(URL: NSURL(string: "/api/comment/add")!)
        request.HTTPMethod = "POST"
        request.HTTPBodyStream = NSInputStream(URL: bodyTempFile)
        return request
    }
    
    private func tempFile() -> NSURL {
        let tempDirectory = NSURL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        return tempDirectory.URLByAppendingPathComponent(NSUUID().UUIDString)
    }
}
