//
//  CommentAddRequest.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/12/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

class CommentAddRequestBody: NSObject {
    
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
        
        try writer.appendPlaintext(String(parameters.sequenceID), withFieldName: "sequence_id")
        
        if let text = parameters.text {
            try writer.appendPlaintext(text, withFieldName: "text")
        }
        
        if let realtime = parameters.realtimeComment {
            try writer.appendPlaintext( String(realtime.assetID), withFieldName: "asset_id" )
            try writer.appendPlaintext( String(realtime.time), withFieldName: "realtime" )
        }
        
        /*if let profileImageURL = profileUpdate?.profileImageURL,
            let pathExtension = profileImageURL.pathExtension,
            let mimeType = profileImageURL.vsdk_mimeType {
                try writer.appendFileWithName("profile_image.\(pathExtension)", contentType: mimeType, fileURL: profileImageURL, fieldName: "profile_image")
        }*/
        
        try writer.finishWriting()
        return Output(fileURL: bodyTempFile, contentType: writer.contentTypeHeader() )
    }
}

public struct CommentParameters {
    
    public struct RealtimeComment {
        public let time: Double
        public let assetID: Int64
        
        public init( time: Double, assetID: Int64 ) {
            self.time = time
            self.assetID = assetID
        }
    }
    
    public let sequenceID: Int64
    public let text: String?
    public let mediaURL: NSURL?
    public let mediaType: MediaAttachmentType?
    public let realtimeComment: RealtimeComment?
    
    public init( sequenceID: Int64, text: String?, mediaURL: NSURL?, mediaType: MediaAttachmentType?, realtimeComment: RealtimeComment? ) {
        self.sequenceID = sequenceID
        self.text = text
        self.mediaURL = mediaURL
        self.mediaType = mediaType
        self.realtimeComment = realtimeComment
    }
}

/// Adds a comment to a particular sequence
public struct CommentAddRequest: RequestType {
    
    private let requestBody: CommentAddRequestBody.Output
    private let requestBodyWriter = CommentAddRequestBody()
    
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
