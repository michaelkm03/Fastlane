//
//  RequestBodyWriter.swift
//  victorious
//
//  Created by Tian Lan on 1/12/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

struct RequestBodyWriterOutput {
    let fileURL: NSURL
    let contentType: String
}

protocol RequestBodyWriter {
    
    typealias RequestBodyParameter
    
    /// URL to the temporary file storing the information of request body
    var bodyTempFile: NSURL { get }
    
    /// Writes a post body for an HTTP request to a temporary file and returns the URL of that file.
    func write(parameters parameters: RequestBodyParameter) throws -> RequestBodyWriterOutput
}

extension RequestBodyWriter {
    
    func createBodyTempFile() -> NSURL {
        let tempDirectory = NSURL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        return tempDirectory.URLByAppendingPathComponent("requestBody.tmp")
    }
    
    func removeBodyTempFile() {
        let _ = try? NSFileManager.defaultManager().removeItemAtURL(bodyTempFile)
    }
}
