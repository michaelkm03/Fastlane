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
        let request = NSMutableURLRequest(URL: NSURL(string: "/api/purchase")!)
        request.HTTPMethod = "POST"
        request.HTTPBodyStream = NSInputStream(URL: requestBody.fileURL)
        request.addValue( requestBody.contentType, forHTTPHeaderField: "Content-Type" )
        return request
    }
    
    public init?(data: NSData) {
        guard data.length > 0 else {
            return nil
        }
        do {
            requestBodyWriter = ValidateReceiptRequestBodyWriter(data: data)
            requestBody = try requestBodyWriter.write()
        } catch {
            return nil
        }
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws {
        requestBodyWriter.removeBodyTempFile()
    }
}
