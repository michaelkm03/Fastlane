//
//  TemplateRequest.swift
//  victorious
//
//  Created by Josh Hinman on 1/21/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public struct TemplateRequest: RequestType {
    
    public init() { }
    
    public var urlRequest: URLRequest {
        return URLRequest(url: URL(string: "/api/template")!)
    }
    
    public func parseResponse(_ response: URLResponse, toRequest request: URLRequest, responseData: Data, responseJSON: JSON) throws -> Data {
        return responseData
    }
}
