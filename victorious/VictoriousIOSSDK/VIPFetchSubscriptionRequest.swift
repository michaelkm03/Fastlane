//
//  VIPFetchSubscriptionRequest.swift
//  victorious
//
//  Created by Sharif Ahmed on 7/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public struct VIPFetchSubscriptionRequest: RequestType {
    public let url: NSURL
    
    public init?(apiPath: APIPath) {
        guard let url = apiPath.url else {
            return nil
        }
        
        self.url = url
    }
    
    public var urlRequest: NSURLRequest {
        return NSURLRequest(URL: url)
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> [String] {
        return responseJSON["payload"]["subscription_id"].array?.flatMap({ $0.string }) ?? []
    }
}
