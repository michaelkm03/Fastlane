//
//  VIPPurchaseRequestBodyWriter.swift
//  victorious
//
//  Created by Patrick Lynch on 3/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class VIPPurchaseRequestBodyWriter: NSObject, RequestBodyWriterType {
    
    struct Output {
        let fileURL: NSURL
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
        let writer = VMultipartFormDataWriter(outputFileURL: bodyTempFileURL)
        try writer.appendData(data.base64EncodedDataWithOptions([]), withFieldName:"apple_receipt")
        try writer.finishWriting()
        return Output(fileURL: bodyTempFileURL, contentType: writer.contentTypeHeader() )
    }
}
