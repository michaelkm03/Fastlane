//
//  LogoutRequest.swift
//  victorious
//
//  Created by Patrick Lynch on 11/23/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public struct LogoutRequest: RequestType {
    
    public init() {}
    
    public var urlRequest: URLRequest {
        return URLRequest(url: URL(string: "/api/logout")!)
    }
    
    public func parseResponse(_ response: URLResponse, toRequest request: URLRequest, responseData: Data, responseJSON: JSON) throws {
        // Protocol conformance
    }
}
