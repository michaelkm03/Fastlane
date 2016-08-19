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
    private let url: NSURL
    
    public var urlRequest: NSURLRequest {
        let request = NSMutableURLRequest(URL: url)
        request.HTTPBodyStream = NSInputStream(URL: requestBody.fileURL)
        request.HTTPMethod = "POST"
        request.addValue( requestBody.contentType, forHTTPHeaderField: "Content-Type" )
        return request
    }
    
    public init?(data: NSData, url: NSURL) {
        self.url = url
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
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> VIPStatus  {
        requestBodyWriter.removeBodyTempFile()
        
        if let vipStatus = responseJSON["payload"].arrayValue.flatMap({ VIPStatus(json: $0["vip"]) }).first {
            return vipStatus
        }
        throw ResponseParsingError()
    }
}
