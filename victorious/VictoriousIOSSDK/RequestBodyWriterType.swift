//
//  RequestBodyWriterType.swift
//  victorious
//
//  Created by Patrick Lynch on 1/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Defines an object that for creates a large HTTP request POST body in temporary files.
/// This is particularly useful for large bodies, such as those that contain images or other media.
protocol RequestBodyWriterType: class {
    
    /// A type representing the multipart form output
    associatedtype Output
    
    /// URL to the temporary file storing the information of request body
    var bodyTempFileURL: NSURL? { get }
    
    /// Writes a post body for an HTTP request to a temporary file and returns the URL of that file.
    func write() throws -> Output
}

extension RequestBodyWriterType {
    
    var bodyTempFileURL: NSURL? {
        let tempDirectory = NSURL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        return tempDirectory.URLByAppendingPathComponent("requestBody.tmp")
    }
    
    func removeBodyTempFile() {
        guard let bodyTempFileURL = bodyTempFileURL else {
            return
        }

        let _ = try? NSFileManager.defaultManager().removeItemAtURL(bodyTempFileURL)
    }
}
