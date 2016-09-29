//
//  VIPFetchSubscriptionRequest.swift
//  victorious
//
//  Created by Sharif Ahmed on 7/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public struct VIPFetchSubscriptionRequest: RequestType {
    public let url: URL
    
    public init?(apiPath: APIPath) {
        guard let url = apiPath.url else {
            return nil
        }
        
        self.url = url
    }
    
    public var urlRequest: URLRequest {
        return URLRequest(url: url)
    }
    
    public func parseResponse(response: URLResponse, toRequest request: URLRequest, responseData: Data, responseJSON: JSON) throws -> [String] {
        return responseJSON["payload"]["subscription_id"].array?.flatMap({ $0.string }) ?? []
    }
}
