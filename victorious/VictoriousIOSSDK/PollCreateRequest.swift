//
//  PollCreateRequest.swift
//  victorious
//
//  Created by Patrick Lynch on 1/5/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct PollAnswer {
    let label: String
    let mediaURL: NSURL
    
    public init(label: String, mediaURL: NSURL) {
        self.label = label
        self.mediaURL = mediaURL
    }
}

public struct PollParameters {
    let name: String
    let question: String
    let description: String
    let answers: [PollAnswer]
    
    public init(let name: String, question: String, description: String, answers: [PollAnswer] ) {
        self.name = name
        self.question = question
        self.description = description
        self.answers = answers
    }
}

/// Adds a comment to a particular sequence
public struct PollCreateRequest: RequestType {
    
    let requestBody: RequestBodyWriter.Output
    let requestBodyWriter = RequestBodyWriter()
    
    public var urlRequest: NSURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: "/api/poll/create")!)
        request.HTTPMethod = "POST"
        request.HTTPBodyStream = NSInputStream(URL: requestBody.fileURL)
        request.addValue( requestBody.contentType, forHTTPHeaderField: "Content-Type" )
        return request.copy() as! NSURLRequest
    }
    
    public init?( parameters: PollParameters ) {
        do {
            self.requestBody = try requestBodyWriter.write( parameters: parameters )
        } catch {
            return nil
        }
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> String {
        let sequenceID = responseJSON["payload"]["sequence_id"]
        
        guard let pollSequenceRemoteID = sequenceID.string else {
            throw ResponseParsingError()
        }
        return pollSequenceRemoteID
    }
}

extension PollCreateRequest {
    
    /// An object that handles writing multipart form input for POST methods for /api/poll/create endpoint
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
        func write( parameters parameters: PollParameters ) throws -> Output {
            let writer = VMultipartFormDataWriter(outputFileURL: bodyTempFile)
            
            try writer.appendPlaintext( parameters.name, withFieldName: "name")
            try writer.appendPlaintext( parameters.description, withFieldName: "description")
            try writer.appendPlaintext( parameters.question, withFieldName: "question")
            
            var i = 1
            for answer in parameters.answers {
                try writer.appendPlaintext( parameters.question, withFieldName: "answer\(i)_label")
                
                if let pathExtension = answer.mediaURL.pathExtension,
                    let mimeType = answer.mediaURL.vsdk_mimeType {
                        try writer.appendFileWithName("media_data.\(pathExtension)",
                            contentType: mimeType,
                            fileURL: answer.mediaURL,
                            fieldName: "answer\(i)_media"
                        )
                }
                
                i++
            }
            
            try writer.finishWriting()
            
            return Output(fileURL: bodyTempFile, contentType: writer.contentTypeHeader() )
        }
    }
}