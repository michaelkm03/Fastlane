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
public struct CommentAddRequest: RequestType {
    
    private let requestBody: RequestBodyWriter.Output
    private let requestBodyWriter = RequestBodyWriter()
    
    public var urlRequest: NSURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: "/api/comment/add")!)
        request.HTTPMethod = "POST"
        request.HTTPBodyStream = NSInputStream(URL: requestBody.fileURL)
        request.addValue( requestBody.contentType, forHTTPHeaderField: "Content-Type" )
        return request.copy() as! NSURLRequest
    }
    
    public init?( parameters: CommentParameters ) {
        do {
            self.requestBody = try requestBodyWriter.write(parameters: parameters)
        } catch {
            return nil
        }
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> Comment {
        guard let comment = Comment(json: responseJSON["payload"]) else {
            throw ResponseParsingError()
        }
        return comment
    }
}

extension CommentAddRequest {
    
    /// An object that handles writing multipart form input for POST methods for /api/comment/add endpoint
    class RequestBodyWriter: NSObject {
        
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
        func write( parameters parameters: CommentParameters ) throws -> Output {
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
            
            return Output(fileURL: bodyTempFile, contentType: writer.contentTypeHeader() )
        }
    }
}
