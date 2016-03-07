//
//  ValidateReceiptRequest.swift
//  victorious
//
//  Created by Patrick Lynch on 3/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public struct ValidateReceiptRequest: RequestType {
    
    private let requestBodyWriter: ValidateReceiptRequestBodyWriter
    private let requestBody: ValidateReceiptRequestBodyWriter.Output
    
    public var urlRequest: NSURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: "/api/receipt/validate")!)
        request.HTTPMethod = "POST"
        request.HTTPBodyStream = NSInputStream(URL: requestBody.fileURL)
        request.addValue( requestBody.contentType, forHTTPHeaderField: "Content-Type" )
        return request
    }
    
    public init?(data: NSData) {
        do {
            requestBodyWriter = ValidateReceiptRequestBodyWriter(data: data)
            requestBody = try requestBodyWriter.write()
        } catch {
            return nil
        }
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> Bool {
        requestBodyWriter.removeBodyTempFile()
        return true
    }
}

class ValidateReceiptRequestBodyWriter: NSObject, RequestBodyWriterType {
    
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
        try writer.appendData(data, withFieldName: "receipt")
        try writer.finishWriting()
        return Output(fileURL: bodyTempFileURL, contentType: writer.contentTypeHeader() )
    }
}
