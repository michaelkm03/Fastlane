//
//  ValidateReceiptRequestBodyWriter.swift
//  victorious
//
//  Created by Patrick Lynch on 3/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class ValidateReceiptRequestBodyWriter: NSObject, RequestBodyWriterType {
    
    struct Output {
        let fileURL: URL
        let contentType: String
    }
    
    let data: NSData
    
    init( data: NSData ) {
        self.data = data
    }
    
    deinit {
        removeBodyTempFile()
    }
    
    func write() throws -> Output {
        guard let bodyTempFileURL = bodyTempFileURL else {
            throw URLError(.unsupportedURL)
        }
        let writer = VMultipartFormDataWriter(outputFileURL: bodyTempFileURL)
        try writer.append(data.base64EncodedData(options: []), withFieldName: "apple_receipt")
        try writer.finishWriting()
        return Output(fileURL: bodyTempFileURL, contentType: writer.contentTypeHeader() )
    }
}
