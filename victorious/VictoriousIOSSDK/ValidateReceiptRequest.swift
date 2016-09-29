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
    private let url: URL
    
    public init?(apiPath: APIPath, data: NSData) {
        guard let url = apiPath.url else {
            return nil
        }
        
        guard data.length > 0 else {
            return nil
        }
        
        self.url = url
        
        do {
            requestBodyWriter = ValidateReceiptRequestBodyWriter(data: data)
            requestBody = try requestBodyWriter.write()
        } catch {
            return nil
        }
    }
    
    public var urlRequest: URLRequest {
        var request = URLRequest(url: url)
        request.httpBodyStream = InputStream(url: requestBody.fileURL as URL)
        request.httpMethod = "POST"
        request.addValue(requestBody.contentType, forHTTPHeaderField: "Content-Type")
        return request
    }
    
    public func parseResponse(response: URLResponse, toRequest request: URLRequest, responseData: Data, responseJSON: JSON) throws -> VIPStatus {
        requestBodyWriter.removeBodyTempFile()
        
        guard let vipStatus = VIPStatus(json: responseJSON["payload"]["vip"]) else {
            throw ResponseParsingError()
        }
        
        return vipStatus
    }
}
