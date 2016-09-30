//
//  CreateAlertRequest.swift
//  victorious
//
//  Created by Patrick Lynch on 12/18/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public struct CreateAlertRequest: RequestType {
    public let additionalParameters: [String: AnyObject]?
    public let type: String
    
    public var urlRequest: URLRequest {
        var urlRequest = URLRequest(url: URL(string: "/api/alert/create")!)
        
        var requestParameters: [String: String] = ["type": type]
        
        if let additionalParameters = additionalParameters {
            let jsonData = try! JSONSerialization.data(withJSONObject: additionalParameters, options: [])
            let paramsString = String(data: jsonData, encoding: String.Encoding.utf8)
            requestParameters["params"] = paramsString
        }
        
        urlRequest.vsdk_addURLEncodedFormPost(requestParameters)
        return urlRequest
    }
    
    public init(type: String, additionalParameters: [String: AnyObject]? = nil) {
        self.type = type
        self.additionalParameters = additionalParameters
    }
    
    public func parseResponse(_ response: URLResponse, toRequest request: URLRequest, responseData: Data, responseJSON: JSON) throws {
        // Protocol conformance
    }
}
