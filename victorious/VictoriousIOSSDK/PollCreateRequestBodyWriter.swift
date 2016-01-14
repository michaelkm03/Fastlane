//
//  PollCreateRequestBodyWriter.swift
//  victorious
//
//  Created by Tian Lan on 1/13/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// An object that handles writing multipart form input for POST methods for /api/poll/create endpoint
class PollCreateRequestBodyWriter: RequestBodyWriter {
    
    var bodyTempFile: NSURL {
        return createBodyTempFile()
    }
    
    deinit {
        removeBodyTempFile()
    }
    
    /// Writes a post body for an HTTP request to a temporary file and returns the URL of that file.
    func write( parameters parameters: PollParameters ) throws -> RequestBodyWriterOutput {
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
        
        return RequestBodyWriterOutput(fileURL: bodyTempFile, contentType: writer.contentTypeHeader() )
    }
}
