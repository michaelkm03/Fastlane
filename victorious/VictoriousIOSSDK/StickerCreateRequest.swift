//
//  StickerCreateRequest.swift
//  victorious
//
//  Created by Sharif Ahmed on 9/27/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public class StickerCreateRequest: RequestType {
    public var urlRequest: URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = formParams.vsdk_urlEncodedString().data(using: .utf8)
        return request
    }
    
    private let url: URL
    private let formParams: [String: String]
    
    public init?(apiPath: APIPath, formParams: [String: String]) {
        guard let url = apiPath.url else {
            return nil
        }
        
        self.url = url
        self.formParams = formParams
    }
    
    public func parseResponse(_ response: URLResponse, toRequest request: URLRequest, responseData: Data, responseJSON: JSON) throws -> Void {}
}
