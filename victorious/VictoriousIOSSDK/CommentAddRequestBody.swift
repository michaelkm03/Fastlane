//
//  CommentAddRequestBody.swift
//  victorious
//
//  Created by Patrick Lynch on 12/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

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
        
        // TODO: FINISH THIS!
        /*if let profileImageURL = profileUpdate?.profileImageURL,
        let pathExtension = profileImageURL.pathExtension,
        let mimeType = profileImageURL.vsdk_mimeType {
        try writer.appendFileWithName("profile_image.\(pathExtension)", contentType: mimeType, fileURL: profileImageURL, fieldName: "profile_image")
        }*/
        
        try writer.finishWriting()
        return Output(fileURL: bodyTempFile, contentType: writer.contentTypeHeader() )
    }
}