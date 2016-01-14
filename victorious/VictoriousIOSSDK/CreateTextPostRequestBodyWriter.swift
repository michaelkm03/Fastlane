//
//  CreateTextPostRequestBodyWriter.swift
//  victorious
//
//  Created by Tian Lan on 1/13/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class CreateTextPostRequestBodyWriter: RequestBodyWriter {
    
    var bodyTempFile: NSURL {
        return createBodyTempFile()
    }
    
    func write(parameters parameters: TextPostParameters) throws -> RequestBodyWriterOutput {
        
        let writer = VMultipartFormDataWriter(outputFileURL: bodyTempFile)
        
        try writer.appendPlaintext(parameters.content, withFieldName: "content")
        
        if (parameters.backgroundColor == nil && parameters.backgroundImageURL == nil) {
            throw NSError(domain: "com.createtextpost.parameters", code: -1, userInfo: nil)
        }
        
        if let color = parameters.backgroundColor {
            try writer.appendPlaintext(color.v_hexString(), withFieldName: "background_color")
        }
        
        if let url = parameters.backgroundImageURL {
            if let pathExtension = url.pathExtension,
                let mimeType = url.vsdk_mimeType {
                    try writer.appendFileWithName("media_data.\(pathExtension)",
                        contentType: mimeType,
                        fileURL: url,
                        fieldName: "background_image"
                    )
            }
        }
        
        try writer.finishWriting()
        
        return RequestBodyWriterOutput(fileURL: bodyTempFile, contentType: writer.contentTypeHeader())
    }
}
